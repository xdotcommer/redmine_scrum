module RedmineScrum
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        acts_as_list  :column => 'backlog_rank', :scope => :sprint
        
        belongs_to    :sprint
        belongs_to    :estimation
        has_many      :commitments
        has_many      :defects
        
        # before_validation   :assign_to_devteam
        before_validation_on_create :hold_backlog_rank
        # before_save   :set_defaults_update_aging_and_stuff
        after_create  :set_backlog_rank
        # after_save    :update_dev_stats_sprint_totals_and_send_mail
        
        named_scope   :stories, :conditions => {:tracker_id => Sprint::STORY_TRACKERS}
        named_scope   :bugs, :conditions => {:tracker_id => Sprint::BUG_TRACKERS}
        named_scope   :distractions, :conditions => {:tracker_id => Sprint::DISTRACTION_TRACKERS}
        named_scope   :for_sprint_and_developer, lambda { |s,d| {:conditions => {:sprint_id => s, :assigned_to_id => d}} }
        named_scope   :open, :conditions => ["issue_statuses.is_closed = ?", false], :include => :status
        named_scope   :pending, :conditions => {:status_id => IssueStatus.pending.try(:id)}
        named_scope   :closed, :conditions => ["issue_statuses.is_closed = ?", true], :include => :status
        named_scope   :ordered_by_rank, :order => 'backlog_rank asc'
        named_scope   :limit_to, lambda { |n| {:limit => n} }
        named_scope   :ready_for_review, :conditions => ['custom_values.value = ? AND custom_fields.name = ?', "Ready for Review", 'Story Readiness'], :include => {:custom_values =>  :custom_field}
        named_scope   :work_in_progress, :conditions => ['(custom_values.value != ? AND custom_fields.name = ?) OR custom_values.value IS NULL', "Ready for Review", 'Story Readiness'], :include => {:custom_values =>  :custom_field}
        named_scope   :estimated, :conditions => 'estimation_id IS NOT NULL AND estimations.name != "Spike"', :include => :estimation


        # Add visible to Redmine 0.8.x
        unless respond_to?(:visible)
          named_scope :visible, lambda {|*args| { :include => :project,
              :conditions => Project.allowed_to_condition(args.first || User.current, :view_issues) } }
        end
      end

    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      def is_blocked
        ! blocker.blank?
      end
      
      def blocker
        custom_values.find_by_custom_field_id(CustomField.find_or_create_by_name("BLOCKED ON").id).try(:value)
      end
      
      def code_review
        custom_values.find_by_custom_field_id(CustomField.find_or_create_by_name("Code Review").id).try(:value)
      end
      
      def set_mailer_flag
        @new_assignment = sprint.commitable? && assigned_to_id_changed? && assigned_to.try(:name) != "Development Team"
        true
      end

      def send_mail_to_dev
        debugger
        StoryAssignmentMailer.deliver_issue_summary(self) if @new_assignment
        true
      end

      def to_json(opts = {})
        super(opts.merge(:methods => [:age, :blocker, :is_blocked, :code_review]))
      end
      
      def update_sprint_totals
        debugger
        return unless sprint && sprint.commitable?
        sprint.set_commitments if sprint.committed_points == 0 && sprint.committed_stories == 0
        sprint.update_totals
        true
      end
      
      def update_from_attributes(attributes)
        self.estimation_id  = attributes[:estimation_id]
        self.sprint_id      = attributes[:sprint_id]
        self.assigned_to_id = attributes[:user_id]
        save!
      end
      
      def is_story?
        Sprint::STORY_TRACKERS.include? tracker_id
      end
      
      def ready_for_review?
        value = custom_values.find(:first, :conditions => ['custom_fields.name = ?', 'Story Readiness'], :include => :custom_field)
        value.try(:value) == "Ready for Review"
      end
      
      def age
        if closed_on && opened_on
          n = ( (opened_on.to_date..closed_on.to_date) ).select {|d| (1..5).include? d.wday }.size
        elsif opened_on
          n = ( (opened_on.to_date..Date.today) ).select {|d| (1..5).include? d.wday }.size
        else
          return nil
        end

        (n == 0) ? 0 : n - 1
      end
      
      def high_or_critical?
        %w(High Critical).include? priority.try(:name)
      end
      
      def commitment
        commitments.find_by_sprint_id(sprint.id)
      end
      
      def update_developer_stats
        debugger
        return true unless assigned_to && sprint.commitable?
        developer_stat = DeveloperStat.find_by_sprint_id_and_user_id(sprint_id, assigned_to_id) || DeveloperStat.new(:sprint => sprint, :user => assigned_to)
        developer_stat.update_details_for(self)
        developer_stat.save
        true
      end
      
      def update_aging
        debugger
        set_opened_on
        set_closed_on
        true
      end
      
      def set_closed_on
        return true unless sprint.commitable? && status_id_changed?
        
        self.closed_on = Date.today if status.try(:is_closed?)
      end
      
      def set_opened_on
        return true unless sprint.start_date && sprint.end_date && sprint.commitable?
        
        if assigned_to_id_changed? 
          if assigned?
            if Date.today < sprint.start_date
              self.opened_on = sprint.start_date
            elsif Date.today > sprint.end_date
              self.opened_on = nil
            else
              self.opened_on = Time.now
            end
          elsif unassigned?
            self.opened_on = nil
          end
        end
      end
      
      def assigned?
        assigned_to && assigned_to != dev_team
      end
      
      def unassigned?
        ! assigned?
      end
      
      def empty_sprint?
        sprint.nil? || sprint.end_date.nil? || sprint.start_date.nil?
      end
      
      def assign_to_devteam
        debugger
        if empty_sprint? || unassigned? && Date.today >= sprint.start_date && Date.today <= sprint.end_date
          if empty_sprint? && assigned_to_id && assigned_to.name != "Development Team"
            errors.add(:assigned_to_id, "cannot be assigned outside of the current sprint") 
            return false
          else
            self.assigned_to = dev_team
          end
        end
        true
      end
      
      def set_defaults_update_aging_and_stuff
        denormalize_data
        reset_qa
        update_aging
        set_mailer_flag
      end
      
      def update_dev_stats_sprint_totals_and_send_mail
        update_developer_stats
        update_sprint_totals
        send_mail_to_dev
      end
      
      def dev_team
        User.find_by_login("dev_team")
      end
      
      def denormalize_data
        debugger
        self.sprint_name  = sprint.try(:name)
        self.story_points = estimation.try(:value)
        true
      end
      
      def hold_backlog_rank
        debugger
        unless backlog_rank.blank?
          @hold_rank_because_of_acts_as_list = backlog_rank
        end
        true
      end
      
      def set_backlog_rank
        debugger
        if @hold_rank_because_of_acts_as_list
          update_attribute(:backlog_rank, @hold_rank_because_of_acts_as_list) 
        end
        true
      end
      
      def reset_qa
        debugger
        return true unless status_id_changed?# || new_record?

        if status.is_pending? || status.is_reopened?
          if qa_used_to_be == "Needed" || qa_used_to_be == "Not Needed"
            self.qa = qa_used_to_be
          else # just to make sure
            self.qa = "Needed"
          end
        elsif ! status.is_closed?
          # set this so we know what to reset the qa status to
          self.qa_used_to_be = qa if qa == "Needed" || qa == "Not Needed"
        end
        true
      end
    end    
  end
end
