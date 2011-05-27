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
      def create_snapshots_for_yesterday
        last_id      = nil
        
        for_yesterday.each do |journal|
          
          # don't re-run for the same issue (or same developer?)
          next if journal.journalized_id == last_id
          last_id = journal.journalized_id

          Burndown.log_from_journal journal
        end
      end
      
      def for_yesterday
        find(:all, :conditions => ["created_on >= ? AND created_on < ? AND journalized_type='Issue'", 1.day.ago.beginning_of_day, Time.now.beginning_of_day], :include => [:details, :issue], :order => 'journalized_id ASC')
      end      
    end
    
    module InstanceMethods
      def log_stats
        return unless jouranlized_type == "Issue"
        
        reload
        Burndown.log_from_journal self
        return true
      end
    end    
  end
end
