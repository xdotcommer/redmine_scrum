ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :backlog, :collection => { :sort => :post, :upcoming => :get }
    project.resources :defects
    project.resources :developer_stats
    project.resources :current_sprint
    project.resources :sprint_average
    project.resources :sprints do |sprint|
      sprint.resources :commitments, :collection => {:bulk_update => :post}
      sprint.resources :histories, :controller => :sprint_histories
      sprint.resources :burndowns
      sprint.resources :scrumboards
    end
  end
end