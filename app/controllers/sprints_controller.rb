class SprintsController < RedmineScrumController
  unloadable

  before_filter :find_versions
  before_filter :find_sprint, :only => [:edit, :update, :destroy]

  def index
    if params[:since]
      @sprints        = Sprint.all(:conditions => ["start_date >= ? AND end_date <= ?", Date.parse(params[:since]), Date.today], :order => 'end_date desc')
    else
      @sprints        = Sprint.all(:order => 'end_date desc')
    end

    @bug_trackers   = Sprint::BUG_TRACKERS
    @story_trackers = Sprint::STORY_TRACKERS

    respond_to do |wants|
      wants.html
      wants.json do
        if params[:chart].blank?
          @sprints_data = DeveloperStatFlot.bar('sprints') do |f|
            f.series_for("Completed Points", @sprints, :x => :id, :y => :completed_points)
          end
        else
          @sprints_data = DeveloperStatFlot.bar('sprints') do |f|
            f.xaxis({:tickSize => '.1', :tickDecimals => true})
            f.series_for(params[:chart].humanize, @sprints, :x => :id, :y => params[:chart].to_sym)
          end
        end

        render :json => @sprints_data
      end
    end
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
      @sprint.save
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
