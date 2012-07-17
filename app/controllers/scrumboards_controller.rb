class ScrumboardsController < RedmineScrumController
  unloadable
  
  before_filter :setup_sprints

  def index
    @scrumboard = Scrumboard.new(@sprint)
    
    respond_to do |format|
      format.html 
      format.json do 
        render :json => {:sprint => @scrumboard.sprint.to_json(:methods => [:open_points, :percent_complete]), :developer_boards => @scrumboard.developer_boards}
      end
    end
  end
end