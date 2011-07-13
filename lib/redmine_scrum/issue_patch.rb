module RedmineScrum
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        belongs_to    :sprint
        belongs_to    :estimation
        has_one       :commitment
        has_many      :defects
        
        before_save   :denormalize_data, :set_next_backlog_rank, :reset_qa
        after_save    :update_developer_stats
        
        named_scope   :stories, :conditions => {:tracker_id => Sprint::STORY_TRACKERS}
        named_scope   :bugs, :conditions => {:tracker_id => Sprint::BUG_TRACKERS}
        named_scope   :for_sprint_and_developer, lambda { |s,d| {:conditions => {:sprint_id => s, :assigned_to_id => d}} }
        named_scope   :open, :conditions => ["issue_statuses.is_closed = ?", false], :include => :status
        named_scope   :pending, :conditions => {:status_id => IssueStatus.pending.try(:id)}
        named_scope   :closed, :conditions => ["issue_statuses.is_closed = ?", true], :include => :status

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
      def update_from_attributes(attributes)
        custom_values.find_by_custom_field_id(CustomField.find_by_name("Requires Clarification")).update_attribute :value, attributes[:requires_clarification]
        self.estimation_id  = attributes[:estimation_id]
        self.priority_id    = attributes[:priority]
        self.sprint_id      = attributes[:sprint_id]
        self.description    = attributes[:description]
        self.assigned_to_id = attributes[:user_id]
        save!
      end
      
      def is_story?
        Sprint::STORY_TRACKERS.include? tracker_id
      end
      
      def update_developer_stats
        return true unless assigned_to && sprint.commitable?
        developer_stat = DeveloperStat.find_by_sprint_id_and_user_id(sprint_id, assigned_to_id) || DeveloperStat.new(:sprint => sprint, :user => assigned_to)
        developer_stat.update_details_for(self)
        developer_stat.save
      end
      
      def denormalize_data
        self.sprint_name  = sprint.try(:name)
        self.story_points = estimation.try(:value)
      end
      
      def set_next_backlog_rank
        if backlog_rank.blank? && max = Issue.maximum(:backlog_rank)
          self.backlog_rank = max + 1
        end
      end
      
      def reset_qa
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
      end
    end    
  end
end
