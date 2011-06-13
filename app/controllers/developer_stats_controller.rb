class DeveloperStatsController < RedmineScrumController
  unloadable

  def index
    @developers = DeveloperStat.find_by_sql("select distinct(user_name) from developer_stats").map &:user_name
    @developers.sort!
    @sprints    = DeveloperStat.find_by_sql("select distinct(sprint_name) from developer_stats").map &:sprint_name
    @sprints.sort!
    @stats      = DeveloperStat.all(:include => [:sprint], :conditions => ["sprints.end_date < ?", Date.today], :order => 'sprint_name DESC, user_name ASC')
    @current_stats = DeveloperStat.all(:include => [:sprint], :conditions => ["sprints.start_date <= ? AND sprints.end_date >= ?", Date.today, Date.today], :order => 'user_name ASC')
    
    @carryover = DeveloperStatFlot.stacked_bar('carryover') do |f|
      @stats.group_by {|b| b.user_name }.each do |user, sprint|
        f.series_for(user, sprint, :x => :sprint_id, :y => :carryover_points, :tooltip => lambda {|r| "#{r.user_name} has #{r.carryover_points} points carrying over" })
      end
    end

    @days_to_pending = DeveloperStatFlot.stacked_bar('carryover') do |f|
      @stats.group_by {|b| b.user_name }.each do |user, sprint|
        f.series_for(user, sprint, :x => :sprint_id, :y => :days_until_first_story_pending, :tooltip => lambda {|r| "#{r.user_name} took #{r.days_until_first_story_pending} days to submit first story" })
      end
    end  
  end
end
