class ScrumboardsController < RedmineScrumController
  unloadable

  def index
    @sprint = params[:sprint_id] ? Sprint.find(params[:sprint_id]) : Sprint.current
    
    debugger
    @scrumboard = Scrumboard.new(@sprint)
  end
end