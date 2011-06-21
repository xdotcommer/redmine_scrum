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
    
    def view_issues_show_description_bottom(context={})
      context[:controller].send(:render_to_string, {:partial => "issues/show_description_bottom", 
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
      context[:issue].defects.each do |defect|
        if context[:params]["defect_#{defect.id}"]
          defect.update_attributes(context[:params]["defect_#{defect.id}"])
        end
      end
      
      if context[:params][:new_defects]
        context[:params][:new_defects].each do |k, defect|
          context[:issue].defects << Defect.new(defect) unless defect[:description].blank?
        end
      end
    end
    
    def view_layouts_base_html_head(context = {})
      context[:controller].send(:render_to_string, {:partial => "layout/head", :locals => {}})
    end
  end
end