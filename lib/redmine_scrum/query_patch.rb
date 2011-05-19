module RedmineScrum
  module QueryPatch
    def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
  
        # Same as typing in the class 
        base.class_eval do
            unloadable # Send unloadable so it will not be unloaded in development
            base.add_available_column(QueryColumn.new(:story_points, :sortable => "#{Issue.table_name}.story_points"))
            base.add_available_column(QueryColumn.new(:sprint_name, :sortable => "#{Issue.table_name}.sprint_name"))
            base.add_available_column(QueryColumn.new(:backlog_rank, :sortable => "#{Issue.table_name}.backlog_rank"))
            base.add_available_column(QueryColumn.new(:qa, :sortable => "#{Issue.table_name}.qa"))

            alias_method_chain :available_filters, :scrum
            alias_method_chain :sql_for_field, :scrum        
        end
    end
  
    module InstanceMethods
      def available_filters_with_scrum
        @available_filters = available_filters_without_scrum

        scrum_filters = {
          "sprint_name"  => { :type => :list, :order => 1, :values => ::Sprint.all.map(&:name) },
          "backlog_rank" => { :type => :integer, :order => 2 },
          "story_points" => { :type => :list, :order => 3, :values => ::Estimation.all.map(&:name) },
          "qa"           => { :type => :list, :order => 4, :values => ::Sprint::QA_STATUSES }
        }

        return @available_filters.merge(scrum_filters)
      end

      def sql_for_field_with_scrum(field, operator, v, db_table, db_field, is_custom_filter=false)
        return sql_for_field_without_scrum(field, operator, v, db_table, db_field, is_custom_filter)
      end
    end
    
    module ClassMethods
        # Setter for +available_columns+ that isn't provided by the core.
        def available_columns=(v)
            self.available_columns = (v)
        end
  
        # Method to add a column to the +available_columns+ that isn't provided by the core.
        def add_available_column(column)
            self.available_columns << (column)
        end
    end
  end
end
