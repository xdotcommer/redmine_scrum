class ScrumboardsController < RedmineScrumController
  unloadable
  
  before_filter :setup_sprints

  def index
    @scrumboard = Scrumboard.new(@sprint)
    
    respond_to do |format|
      format.html 
      format.json do 
        render :json => @scrumboard.to_json
      end
    end
  end
end