module RedmineScrum
  module JournalDetailPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        mattr_accessor :qa_field

        self.qa_field ||= CustomField.find_by_name("QA")
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      def qa_field
        self.class.qa_field
      end
      
      def qa_change?
        property == "cf" && prop_key.to_i == qa_field.id
      end
      
      def status_change?
        property == "attr" && prop_key == "status_id"
      end
    end    
  end
end
