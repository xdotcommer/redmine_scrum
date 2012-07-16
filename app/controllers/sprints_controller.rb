class SprintsController < RedmineScrumController
  unloadable

  before_filter :find_versions
  before_filter :find_sprint, :only => [:edit, :update, :destroy]

  def index
    @sprints        = Sprint.all(:order => 'end_date desc')
    @bug_trackers   = Sprint::BUG_TRACKERS
    @story_trackers = Sprint::STORY_TRACKERS
  end

  def new
    @sprint = Sprint.new
  end

  def edit
  end

  def create
    @sprint = Sprint.new(params[:sprint])

    if @sprint.save
      flash[:notice] = 'Sprint was successfully created.'
      redirect_to project_sprints_url(@project)
    else
      render :action => "new"
    end
  end

  def update
    if @sprint.update_attributes(params[:sprint])
      @sprint.set_commitments
      flash[:notice] = 'Sprint was successfully updated.'
      redirect_to project_sprints_url(@project)
    else
      render :action => "edit"
    end
  end

  def destroy
    @sprint.destroy
    redirect_to project_sprints_url(@project)
  end

private
  def find_sprint
    @sprint = Sprint.find(params[:id])
  end

  def find_versions
    @versions = Version.all
  end
end
