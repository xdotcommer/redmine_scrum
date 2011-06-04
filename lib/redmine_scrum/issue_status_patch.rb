module RedmineScrum
  module IssueStatusPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        mattr_accessor  :closed_ids, :pending_ids, :open_ids

        named_scope   :stories, :conditions => {:tracker_id => Sprint::STORY_TRACKERS}
        named_scope   :bugs, :conditions => {:tracker_id => Sprint::BUG_TRACKERS}
      end

    end
    
    module ClassMethods
      def pending
        find_by_name("Pending Approval")
      end
      
      def open_ids
        find_all_by_is_closed(false).map(&:id)
      end
      
      def closed_ids
        find_all_by_is_closed(true).map(&:id)
      end
    end
    
    module InstanceMethods
      def is_pending?
        name == "Pending Approval"
      end
      
      def is_reopened?
        name == "Reopened"
      end
    end
  end
end
