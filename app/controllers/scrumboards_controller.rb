class ScrumboardsController < RedmineScrumController
  unloadable

  def index
    @sprints = Sprint.commitable
    @sprint = params[:sprint_id] ? Sprint.find(params[:sprint_id]) : Sprint.current
    @sprint = Sprint.last unless @sprint
    
    @scrumboard = Scrumboard.new(@sprint)
  end
end