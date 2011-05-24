class SprintHistoriesController < RedmineScrumController
  unloadable

  def index
    @sprint      = Sprint.find(params[:sprint_id])
    
    @flot = Flot.new('graph') do |f|
      f.bars
      f.grid :hoverable => true
      f.selection :mode => "xy"
      f.series_for("Story Points", @sprint.issues, :x => :assigned_to_id, :y => :story_points)
      # f.series_for("Hours of Sleep", @migraines, :x => :entry_date, :y => :hours_of_sleep)
      # f.series_for("Restful Night?", @migraines, :x => :entry_date, :y => lambda {|record| record.restful_night ? 5 : 0 }, :options => {:points => {:show => true}, :bars => {:show => false}})
      # f.series_for("Migraines", @migraines, :x => :entry_date, :y => lambda {|record| record.migraine? ? 4 : nil }, :options => {:points => {:show => true}, :bars => {:show => false}})
    end
  end
end
