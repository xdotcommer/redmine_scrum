module RedmineScrum
  class Hooks < Redmine::Hook::ViewListener
    # Additional context fields
    #   :issue  => the issue this is edited
    #   :f      => the form object to create additional fields
    # render_on :view_issues_form_details_top, :partial => 'issues/form_details_bottom'

    def view_issues_form_details_bottom(context={})
      sprints     = Sprint.all(:order => 'is_backlog DESC, name DESC')
      estimations = Estimation.all(:order => 'value ASC')
      context[:controller].send(:render_to_string, {:partial => "issues/form_details_bottom", 
                                :locals => context.merge(:sprints => sprints, :estimations => estimations)})
    end
    
    def view_issues_show_details_bottom(context={})
      context[:controller].send(:render_to_string, {:partial => "issues/show_details_bottom", 
                                :locals => context})
    end
    
    def view_issues_bulk_edit_details_bottom(context = {})
      sprints     = Sprint.all(:order => 'is_backlog DESC, name DESC')
      estimations = Estimation.all(:order => 'value ASC')
      context[:controller].send(:render_to_string, {:partial => "issues/bulk_edit_details_bottom", 
                                :locals => context.merge(:sprints => sprints, :estimations => estimations)})
    end
    
    def view_issues_context_menu_start(context = {})
      sprints     = Sprint.all(:order => 'is_backlog DESC, name DESC')
      estimations = Estimation.all(:order => 'value ASC')
      context[:controller].send(:render_to_string, {:partial => "issues/context_menu_start", 
                                :locals => context.merge(:sprints => sprints, :estimations => estimations)})
    end
    
    def controller_issues_edit_after_save(context = {})
      context[:params][:defects].each do |k, defect_description|
        context[:issue].defects << Defect.new(:description => defect_description) unless defect_description.blank?
      end
    end
  end
end