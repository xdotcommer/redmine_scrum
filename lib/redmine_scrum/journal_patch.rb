module RedmineScrum
  module JournalPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        has_many      :sprint_stats
        
        after_create  :log_stats
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      def log_stats
        return unless journalized_type == "Issue"
        
        reload
        # Burndown.update_from_journal self
        return true
      end
    end    
  end
end
