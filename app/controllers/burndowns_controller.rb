class BurndownsController < RedmineScrumController
  unloadable
  
  before_filter :setup_sprints

  def index
    @burndown = BurndownFlot.area(@sprint) do |f|
      f.series_for("Open", @sprint.burndown, :x => :sprint_day, :y => :open, :tooltip => lambda {|r| "#{r.open} points open" })
      f.series_for("Pending", @sprint.burndown, :x => :sprint_day, :y => :pending, :tooltip => lambda {|r| r.pending == 0 ? "#{r.open} points open" : "#{r.pending} points pending" })
      f.series_for("Reopens", @sprint.burndown, :x => :sprint_day, :y => :display_reopens, :options => {:points => {:show => true}, :lines => {:show => false}})
    end

    respond_to do |format|
      format.html do
      end
      format.json do 
        render :json => @burndown
      end
    end
  end
end