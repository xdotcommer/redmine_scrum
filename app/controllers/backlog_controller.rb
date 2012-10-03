class BacklogController < RedmineScrumController
  unloadable
  
  before_filter :set_variables, :only => [:index]

  def index
    @stories = get_stories(@scope, @limit)
    @count   = @stories.size
    
    date = (Sprint.current || Sprint.last).end_date + 1.day
    @sprint_end_dates = []
    20.times do
      date += 3.weeks
      @sprint_end_dates << date
    end
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
  
  def set_variables
    @limit   = params[:limit] || 50
    @scope   = params[:scope]
    @limit   = @limit.to_i
    @sprint  = params[:sprint_id].blank? ? Sprint.find_by_name("Backlog") : Sprint.find(params[:sprint_id])
    @sprints = Sprint.with_open_stories
    @velocity =  params[:velocity] || SprintAverage.new(2.months.ago).completed_points
  end
  
  def get_stories(scope, limit)
    if scope == "Half Baked"
      @sprint.issues.stories.open.half_baked.limit_to(limit).ordered_by_rank
    elsif scope == "Ready to Estimate"
      @sprint.issues.stories.open.ready_to_estimate.limit_to(limit).ordered_by_rank
    elsif scope == "In Discussion"
      @sprint.issues.stories.open.in_discussion.limit_to(limit).ordered_by_rank
    elsif scope == "Estimated"
      @sprint.issues.stories.open.estimated.limit_to(limit).ordered_by_rank
    else
      @sprint.issues.stories.open.limit_to(limit).ordered_by_rank
    end
  end
end
