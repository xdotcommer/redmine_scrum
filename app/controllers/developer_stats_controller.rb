class DeveloperStatsController < RedmineScrumController
  unloadable

  def index
    @developers = DeveloperStat.find_by_sql("select distinct(user_name) from developer_stats").map &:user_name
    @developers.sort!
    @sprints    = DeveloperStat.find_by_sql("select distinct(sprint_name) from developer_stats").map &:sprint_name
    @sprints.sort!
    @stats      = DeveloperStat.all(:order => 'sprint_name DESC, user_name ASC')
  end
end
