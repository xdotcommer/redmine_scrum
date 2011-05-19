module RedmineScrum
  class Hooks < Redmine::Hook::ViewListener
    # Additional context fields
    #   :issue  => the issue this is edited
    #   :f      => the form object to create additional fields
    # render_on :view_issues_form_details_top, :partial => 'issues/form_details_bottom'

    def view_issues_form_details_bottom(context={})
      sprints = Sprint.all(:order => 'name DESC')
      estimations = Estimation.all(:order => 'value ASC')
      context[:controller].send(:render_to_string, {:partial => "issues/form_details_bottom", 
                                :locals => context.merge(:sprints => sprints, :estimations => estimations)})
    end
    
    def view_issues_show_details_bottom(context={})
      context[:controller].send(:render_to_string, {:partial => "issues/show_details_bottom", 
                                :locals => context})
    end
  end
end