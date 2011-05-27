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
        
        after_create  :update_burndown
        before_save   :denormalize_data, :set_next_backlog_rank
        
        named_scope   :stories, :conditions => {:tracker_id => Sprint::STORY_TRACKERS}
        named_scope   :bugs, :conditions => {:tracker_id => Sprint::BUG_TRACKERS}

        # Add visible to Redmine 0.8.x
        unless respond_to?(:visible)
          named_scope :visible, lambda {|*args| { :include => :project,
              :conditions => Project.allowed_to_condition(args.first || User.current, :view_issues) } }
        end
      end

    end
    
    module ClassMethods
      # def snapshot_all
      #   Issue.find_in_batches do |group|
      #     group.each do |issue|
      #       Burndown.update_from_issue issue
      #     end
      #   end
      # end
      # 
      # def create_snapshots_for(date)
      #   occurring_between(date.beginning_of_day, date.end_of_day).each do |issue|
      #     Burndown.update_from_issue issue
      #   end
      # end
      # 
      # def occurring_between(from, to)
      #   find(:all, :conditions => ["created_on >= ? AND created_on < ?", from, to])
      # end      
    end
    
    module InstanceMethods
      def denormalize_data
        self.sprint_name  = sprint.try(:name)
        self.story_points = estimation.try(:value)
      end
      
      def set_next_backlog_rank
        if backlog_rank.blank? && max = Issue.maximum(:backlog_rank)
          self.backlog_rank = max + 1
        end
      end
      
      def update_burndown
        reload
        # Burndown.update_from_issue self
        return true
      end
    end    
  end
end
