class BurndownsController < RedmineScrumController
  unloadable
  
  before_filter :setup_sprints

  def index
    @burndown = BurndownFlot.area('Burndown') do |f|
      f.series_for("Open", @sprint.burndown, :x => :sprint_day, :y => :open, :tooltip => lambda {|r| "#{r.open} points" })
      f.series_for("Pending", @sprint.burndown, :x => :sprint_day, :y => :pending, :tooltip => lambda {|r| "#{r.pending} points" })
    end
  end
end