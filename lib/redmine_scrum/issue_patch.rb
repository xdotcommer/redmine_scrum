module RedmineScrum
  # Patches Redmine's Issues dynamically.  Adds a +after_save+ filter.
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
        has_many      :sprint_histories
        
        after_save    :create_scrum_issue_stats
        before_save   :denormalize_data, :set_next_backlog_rank
        after_destroy :remove_scrum_issue_stats
        
        named_scope   :stories, :conditions => {:tracker_id => Sprint::STORY_TRACKERS}

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
      def denormalize_data
        self.sprint_name  = sprint.try(:name)
        self.story_points = estimation.try(:value)
      end
      
      def set_next_backlog_rank
        if backlog_rank.blank? && max = Issue.maximum(:backlog_rank)
          self.backlog_rank = max + 1
        end
      end
      
      def create_scrum_issue_stats
        self.reload
        SprintHistory.create_from_issue self
        return true
      end

      def remove_scrum_issue_stats
        SprintHistory.destroy_all(['issue_id = (?)', self.id]) if self.id
      end
    end    
  end
end
