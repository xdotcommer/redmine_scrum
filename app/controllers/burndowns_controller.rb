class BurndownsController < RedmineScrumController
  unloadable

  def index
    @sprints = Sprint.commitable
    @sprint = params[:sprint_id] ? Sprint.find(params[:sprint_id]) : Sprint.current
    @sprint = Sprint.last unless @sprint
    
    @burndown = BurndownFlot.area('Burndown') do |f|
      f.series_for("Open", @sprint.burndown, :x => :sprint_day, :y => :open, :tooltip => lambda {|r| "#{r.open} points" })
      f.series_for("Pending", @sprint.burndown, :x => :sprint_day, :y => :pending, :tooltip => lambda {|r| "#{r.pending} points" })
    end
  end
end