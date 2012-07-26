class DeveloperStatsController < RedmineScrumController
  unloadable

  def index
    if params[:since]
      @stats = DeveloperStat.all(:include => [:sprint], :conditions => ["user_name != 'Development Team' AND user_name != 'Will Schneider' AND user_name != 'Dan Hensgen' AND user_name != 'Stephen McGarrigle' AND sprints.end_date < ? AND sprints.start_date > ?", 2.weeks.from_now.to_date, Date.parse(params[:since])], :order => 'sprint_name DESC, user_name ASC')
    else
      @stats = DeveloperStat.all(:include => [:sprint], :conditions => ["user_name != 'Development Team' AND user_name != 'Will Schneider' AND user_name != 'Dan Hensgen' AND user_name != 'Stephen McGarrigle' AND sprints.end_date < ? AND sprints.start_date > ?", 2.weeks.from_now.to_date, 3.months.ago.to_date], :order => 'sprint_name DESC, user_name ASC')
    end

    @completed_points = DeveloperStatFlot.area('completed_points') do |f|
      f.legend :position => "nw", :noColumns => 2
      @stats.group_by {|b| b.user_name }.each do |user, sprint|
        f.series_for(user, sprint, :x => :sprint_id, :y => :completed_points, :tooltip => lambda {|r| "#{r.user_name} completed #{r.completed_points} points" })
      end
    end

    respond_to do |wants|
      wants.html
      wants.json do
        render :json => @completed_points
      end
    end
  end

  def old_index
    @developers = DeveloperStat.find_by_sql("select distinct(user_name) from developer_stats").map &:user_name
    @developers.sort!
    @sprints    = DeveloperStat.find_by_sql("select distinct(sprint_name) from developer_stats JOIN sprints ON  sprint_id=sprints.id WHERE sprints.start_date < DATE(NOW())").map &:sprint_name
    @sprints.sort!
    @stats      = DeveloperStat.all(:include => [:sprint], :conditions => ["sprints.end_date < ?", Date.today], :order => 'sprint_name DESC, user_name ASC')
    @current_stats = DeveloperStat.all(:include => [:sprint], :conditions => ["sprints.start_date <= ? AND sprints.end_date >= ?", Date.today, Date.today], :order => 'user_name ASC')
    
    @average_completed =  DeveloperStat.sum(:completed_points, :include => [:sprint], :conditions => ["sprints.start_date < ?", Date.today]) / @sprints.size
    @average_committed = DeveloperStat.sum(:committed_points, :include => [:sprint], :conditions => ["sprints.start_date < ?", Date.today]) / @sprints.size
    @developer_averages = {}
    
    @developers.each do |name|
      @developer_averages[name] = {
        :completed_points => (DeveloperStat.sum(:completed_points, :include => [:sprint], :conditions => ["sprints.start_date < ? AND user_name=?", Date.today, name]) / @sprints.size),
        :committed_points => (DeveloperStat.sum(:committed_points, :include => [:sprint], :conditions => ["sprints.start_date < ? AND user_name=?", Date.today, name]) / @sprints.size)
      } 
    end
    
    @carryover = DeveloperStatFlot.stacked_bar('carryover') do |f|
      @stats.group_by {|b| b.user_name }.each do |user, sprint|
        f.series_for(user, sprint, :x => :sprint_id, :y => :carryover_points, :tooltip => lambda {|r| "#{r.user_name} had #{r.carryover_points} points carrying over" })
      end
    end

    @days_to_pending = DeveloperStatFlot.stacked_bar('carryover') do |f|
      @stats.group_by {|b| b.user_name }.each do |user, sprint|
        f.series_for(user, sprint, :x => :sprint_id, :y => :days_until_first_story_pending, :tooltip => lambda {|r| "#{r.user_name} took #{r.days_until_first_story_pending} days to submit first story" })
      end
    end  

    @completed_points = DeveloperStatFlot.stacked_bar('completed_points') do |f|
      @stats.group_by {|b| b.user_name }.each do |user, sprint|
        f.series_for(user, sprint, :x => :sprint_id, :y => :completed_points, :tooltip => lambda {|r| "#{r.user_name} completed #{r.completed_points} points" })
      end
    end
     
    @story_reopens = DeveloperStatFlot.stacked_bar('story_reopens') do |f|
      @stats.group_by {|b| b.user_name }.each do |user, sprint|
        f.series_for(user, sprint, :x => :sprint_id, :y => :story_reopens, :tooltip => lambda {|r| "#{r.user_name} had #{r.story_reopens} story reopens" })
      end
    end
  end
end
