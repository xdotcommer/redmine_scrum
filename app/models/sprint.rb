class Sprint < ActiveRecord::Base
  unloadable

  STORY_TRACKERS       = ["Epic", "Story", "Research", "Lab", "TechDebt"].map {|type| Tracker.find_or_create_by_name(type) }
  BUG_TRACKERS         = ["Bug"].map {|type| Tracker.find_or_create_by_name(type) }
  DISTRACTION_TRACKERS = ["Distraction"].map {|type| Tracker.find_or_create_by_name(type) }

  QA_STATUSES     = ["Needed", "Not Needed", "Succeeded", "Failed"]
  
  DAYS = %w(Mon Tue Wed Thu Fri)

  DEFAULT_DEVELOPER_DAYS = 50
  
  mattr_accessor  :backlog
  
  has_many  :issues, :order => 'backlog_rank'
  has_many  :assigned_tos, :through => :issues
  has_many  :commitments
  has_many  :burndowns, :order => 'sprint_day ASC'
  has_many  :developer_stats
  
  named_scope :recent, lambda { {:conditions => ["end_date >= ? OR name='Backlog' OR name='Icebox'", 14.days.ago], :order => 'name ASC' } }
  named_scope :commitable, :conditions => 'name != "Backlog" AND name != "Icebox"'
  named_scope :past, lambda { {:conditions => ['end_date <= ?', Date.today]} }
  named_scope :with_developer_stats, :include => [:developer_stats], :conditions => 'developer_stats.id > 0'
  named_scope :upcoming, lambda { {:conditions => ['end_date >= ?', Date.today], :order => 'start_date ASC'} }
  named_scope :since, lambda { |date| {:conditions => ['start_date >= ?', date]} }
  named_scope :up_to_current, lambda { {:conditions => ["start_date <= ?", Date.today]} }
  named_scope :in_ascending_order, :order => 'start_date ASC'


  validates_each :start_date, :end_date, :on => :create do |record, attr, value|
    record.errors.add attr, 'already exists' if Sprint.send("find_by_#{attr}".to_sym, value)
  end
  
  validate :start_date_before_end_date
  validates_numericality_of :developer_days
  # TODO
  #validate :not_overlapping_another_sprint
  
  before_save :set_name, :set_developer_days
  before_save :set_commitments, :if => :no_commitments?
  
  belongs_to  :version
  
  # hack for testing
  def self.set_trackers_to_main_project
    project = Project.first
    (STORY_TRACKERS + BUG_TRACKERS).each do |id|
      tracker = Tracker.find(id)
      project.trackers << tracker unless project.trackers.include? tracker
    end
    project.save!
  end

  def self.up_to_current_since(date)
    since(date).up_to_current.in_ascending_order
  end

  def self.with_open_stories
    sql =<<-EOSQL
      select distinct(sprint_name)
      from issues
      left join issue_statuses on issues.status_id = issue_statuses.id
      left join trackers on issues.tracker_id = trackers.id
      where issue_statuses.is_closed=0 AND trackers.name in ("Story", "Research", "Lab", "TechDebt")
    EOSQL
    
    Issue.find_by_sql(sql).map {|i| Sprint.find_by_name(i.sprint_name)}.compact.sort_by(&:name)
  end
  
  def self.backlog
    @@backlog ||= find_by_name("Backlog")
  end
  
  def self.current
    Sprint.find(:first, :conditions => ["start_date <= ? AND end_date >= ?", Date.today, Date.today])
  end
  
  def self.update_burndown_for(date)
    if current_sprint = Sprint.find(:first, :conditions => ["start_date <= ? AND end_date >= ?", date, date])
      date -= 2.days if date.wday == 0
      date -= 1.day  if date.wday == 6
      Burndown::Story.snapshot_users_for current_sprint, date
    end
  end

  def self.create_defaults
    if count == 0
      new(:name => 'Backlog', :is_backlog => true).save(false)
      new(:name => 'Icebox', :is_backlog => false).save(false)
    end
  end

  def self.migrate_existing
    existing_sprint_list = CustomField.find_by_name("Sprint").possible_values
    existing_sprint_list.each do |sprint_name|
      unless sprint_name =~ /^9999/
        unless Sprint.exists? :name => sprint_name
          end_date   = Date.parse sprint_name
          start_date = end_date - 13
          Sprint.create! :name => sprint_name, :end_date => end_date, :start_date => start_date
        end
      end
    end
  end
  
  def to_json(opts = {})
    super(opts.merge(:methods => [:open_points, :percent_complete, :story_points_per_developer_day]))
  end
  
  def day_labels
    labels = []
    day_mappings.each do |k,v|
      v.each do |value|
        labels << [value, k]
      end
    end
    labels
  end
  
  def day_mappings
    days = []
    day_map = {
      "Mon" => [],
      "Tue" => [],
      "Wed" => [],
      "Thu" => [],
      "Fri" => []
    }

    (0..duration).each do |d|
      days << Burndown::Day.new(self, d)
    end
    
    days.each do |day|
      day_map[day.day_of_week] << day.sprint_day
    end
    
    day_map
  end
  
  def burndown
    if active?
      self.class.update_burndown_for(Date.today)
    end
    
    overall = Array.new(duration + 1)
    
    last_day_calculated = Burndown.maximum(:sprint_day, :conditions => ["sprint_id = ?", id]) || 0

    0.upto(duration) do |i|
      overall[i] = Burndown::Day.new(self, i)
      if i == 0
        overall[i].open = committed_points
      elsif i > last_day_calculated
        overall[i].clear_data
      end
    end

    burndowns.group_by {|b| b.sprint_day }.each do |day, devs|
      next if day == 0
      
      devs.each do |dev|
        overall[day].pending += dev.pending_point_count
        overall[day].open += (dev.open_point_count + dev.reopened_point_count)
        overall[day].reopens += dev.reopened_count
      end
    end

    overall
  end
  
  def story_count
    issues.stories.count
  end
  
  def open_story_count
    issues.stories.open.count - issues.stories.pending.count
  end
  
  def closed_story_count
    issues.stories.closed.count
  end
  
  def open_bug_count
    issues.bugs.open.count - issues.bugs.pending.count
  end

  def story_points_per_developer_day
    if developer_days == 0 || developer_days.blank?
      nil
    else
      ('%.2f' % (completed_points.to_f / developer_days.to_f)).to_f
    end
  end

  def closed_bug_count
    issues.bugs.closed.count
  end
  
  def bug_count
    issues.bugs.count
  end

  def commitable?
    ! backlog? && ! icebox?
  end
  
  def backlog?
    name == "Backlog"
  end
  
  def icebox?
    name == "Icebox"
  end
  
  # Only used for dev stats (which need rewriting anyway)
  def sprint_day(date)
    return -1 unless start_date && end_date
    return -1 if date < start_date
    return (duration + 1) if date > end_date

    counter_date = start_date
    day          = 1
    
    while (counter_date < date)
      if counter_date.wday == 0 || counter_date.wday == 6
        counter_date += 1
        next
      else
        counter_date += 1
      end

      day += 1
    end
    
    day
  end
  
  def starting_index
    return nil unless start_date
    DAYS.index(starting_day)
  end
  
  def starting_day
    return nil unless start_date
    start_date.strftime("%a")
  end
  
  def duration
    return 0 unless commitable? && start_date && end_date

    ( (start_date..end_date) ).select {|d| (1..5).include? d.wday }.size
  end
  
  def days_in
    return 0 unless commitable? && start_date && end_date

    if Date.today >= end_date
      duration
    else
      ( (start_date..Date.today) ).select {|d| (1..5).include? d.wday }.size
    end
  end
  
  def percent_complete
    return 0 unless commitable? && duration > 0
    (days_in.to_f / duration.to_f * 100).round
  end
  
  def open_points
    committed_points - pending_points - completed_points
  end
  
  def open_stories
    committed_stories - pending_stories - completed_stories
  end
  
  def no_commitments?
    committed_points == 0 || committed_stories == 0
  end
  
  def set_commitments
    self.committed_points = issues.stories.sum(:story_points)
    self.committed_stories = issues.stories.count
  end

  def calculate_totals
    self.pending_points = issues.stories.pending.sum(:story_points)
    self.pending_stories = issues.stories.pending.count
    self.completed_points = issues.stories.closed.sum(:story_points)
    self.completed_stories = issues.stories.closed.count
    self.defects = Defect.total_for_sprint(id)
    self.reopens = burndowns.sum(:reopened_count)
    self.distractions = issues.distractions.count
    self.bugs = issues.bugs.closed.count
  end
  
  def update_totals
    if issues.count > 0
      calculate_totals
      save
    end
  end

  def active?
    Date.today <= end_date && Date.today >= start_date
  end

private
  def start_date_before_end_date
    return true unless commitable?
    raise self.inspect if end_date.nil?
    if end_date <= start_date
      errors.add(:start_date, 'must be before the end date')
    end
  end

  def set_name
    if end_date
      self.name = "#{end_date.strftime('%Y.%m.%d')}"
    end
  end

  def set_developer_days
    if developer_days.blank?
      self.developer_days = DEFAULT_DEVELOPER_DAYS
    end
  end
end
