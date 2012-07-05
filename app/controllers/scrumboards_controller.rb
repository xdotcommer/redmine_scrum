class ScrumboardsController < RedmineScrumController
  unloadable
  
  before_filter :setup_sprints

  def index
    @scrumboard = Scrumboard.new(@sprint)
  end
end