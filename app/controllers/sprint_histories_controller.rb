class SprintHistoriesController < RedmineScrumController
  unloadable

  def index
    @sprint      = Sprint.find(params[:sprint_id])

    @open_points = BurndownFlot.line('open_points') do |f|
      @sprint.burndowns.group_by {|b| b.user_name }.each do |user, days|
        f.series_for(user, days, :x => :sprint_day, :y => :open_point_count)
      end
    end
    
    @pending_story_points = BurndownFlot.line('pending_story_points') do |f|
      @sprint.burndowns.group_by {|b| b.user_name }.each do |user, days|
        f.series_for(user, days, :x => :sprint_day, :y => lambda {|r| r.open_point_count - r.pending_point_count })
      end
    end

    @pending_stories = BurndownFlot.stacked_bar('pending_stories') do |f|
      @sprint.burndowns.group_by {|b| b.user_name }.each do |user, days|
        f.series_for(user, days, :x => :sprint_day, :y => :pending_count)
      end
    end
    
    @reopened_stories = BurndownFlot.stacked_bar('reopened_stories') do |f|
      @sprint.burndowns.group_by {|b| b.user_name }.each do |user, days|
        f.series_for(user, days, :x => :sprint_day, :y => :reopened_count)
      end
    end
  end
end


# f.series_for("Hours of Sleep", @migraines, :x => :entry_date, :y => :hours_of_sleep)
# f.series_for("Restful Night?", @migraines, :x => :entry_date, :y => lambda {|record| record.restful_night ? 5 : 0 }, :options => {:points => {:show => true}, :bars => {:show => false}})
# f.series_for("Migraines", @migraines, :x => :entry_date, :y => lambda {|record| record.migraine? ? 4 : nil }, :options => {:points => {:show => true}, :bars => {:show => false}})
