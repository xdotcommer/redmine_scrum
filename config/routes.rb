ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :backlog, :collection => { :sort => :post, :upcoming => :get }
    project.resources :defects
    project.resources :developer_stats
    project.resources :sprints do |sprint|
      sprint.resources :commitments, :collection => {:bulk_update => :post}
      sprint.resources :histories, :controller => :sprint_histories
    end
  end
end