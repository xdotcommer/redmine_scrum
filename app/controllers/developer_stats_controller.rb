class DeveloperStatsController < RedmineScrumController
  unloadable

  def index
    @developers = DeveloperStat.find_by_sql("select distinct(user_name) from developer_stats").map &:user_name
    @developers.sort!
    @sprints    = DeveloperStat.find_by_sql("select distinct(sprint_name) from developer_stats").map &:sprint_name
    @sprints.sort!
    @stats      = DeveloperStat.all(:include => [:sprint], :conditions => ["sprints.end_date < ?", Date.today], :order => 'sprint_name DESC, user_name ASC')
    @current_stats = DeveloperStat.all(:include => [:sprint], :conditions => ["sprints.start_date <= ? AND sprints.end_date >= ?", Date.today, Date.today], :order => 'user_name ASC')
  end
end
