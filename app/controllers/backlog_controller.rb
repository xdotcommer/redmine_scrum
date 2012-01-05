class BacklogController < RedmineScrumController
  unloadable

  def index
    @limit   = params[:limit] || 50
    @limit   = @limit.to_i
    @sprint  = params[:sprint_id].blank? ? Sprint.find_by_name("Backlog") : Sprint.find(params[:sprint_id])
    @sprints = Sprint.all(:select => 'name, id')
    @stories = @sprint.issues.stories.open.limit_to(@limit).ordered_by_rank
    @count   = @stories.size
  end
  
  def sort
    params[:stories].each_with_index do |id, index|
      Issue.update_all(['backlog_rank=?', index + 1], ['id=?', id])
    end
    render :nothing => true
  end

  def update
  end

  def update_all
  end
end
