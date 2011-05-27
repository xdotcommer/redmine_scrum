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
      # def create_snapshots_for(date)
      #   last_id      = nil
      #   
      #   occurring_between(date.beginning_of_day, date.end_of_day).each do |journal|
      #     # don't re-run for the same issue (or same developer?)
      #     next if journal.journalized_id == last_id
      #     last_id = journal.journalized_id
      # 
      #     Burndown.update_from_journal journal
      #   end
      # end
      # 
      # def occurring_between(from, to)
      #   find(:all, :conditions => ["created_on >= ? AND created_on < ? AND journalized_type='Issue'", from, to], :include => [:details, :issue], :order => 'journalized_id ASC')
      # end      
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
