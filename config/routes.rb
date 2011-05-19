ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :sprints do |sprint|
      sprint.resources :commitments, :collection => {:bulk_update => :post}
    end
  end
end