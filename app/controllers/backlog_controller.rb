class BacklogController < RedmineScrumController
  unloadable

  def index
    @limit   = params[:limit] || 50
    @limit   = @limit.to_i
    @sprint  = params[:sprint_id].blank? ? Sprint.find_by_name("Backlog") : Sprint.find(params[:sprint_id])
    @sprints = Sprint.with_open_stories
    @stories = @sprint.issues.stories.open.limit_to(@limit).ordered_by_rank
    @count   = @stories.size
  end
  
  def sort
    # raise params.inspect
    if params[:stories]
      update_backlog_rank_for(params[:stories])
    else
      params.keys.each do |key|
        if key =~ /^stories_(.*)$/
          update_backlog_rank_for(params.send(:[], :"stories_#{$1}"))
        end
      end
    end
    render :nothing => true
  end

  def upcoming
    @sprints            = Sprint.upcoming
    @sprints_to_stories = {}
    @sprints.each do |sprint|
      @sprints_to_stories[sprint.name.to_s] = sprint.issues.stories.open.ordered_by_rank.to_a
    end
  end
  
private
  def update_backlog_rank_for(stories)
    stories.each_with_index do |id, position|
      Issue.update_all(['backlog_rank=?', position + 1], ['id=?', id])
    end
  end
end
