class Sprint < ActiveRecord::Base
  unloadable

  STORY_TRACKERS  = ["Epic", "Story", "Research", "Lab", "TechDebt"].map {|type| Tracker.find_or_create_by_name(type) }
  BUG_TRACKERS    = ["Bug"].map {|type| Tracker.find_or_create_by_name(type) }

  QA_STATUSES     = ["Needed", "Not Needed", "Succeeded", "Failed"]
  
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
  
  validates_each :start_date, :end_date, :on => :create do |record, attr, value|
    record.errors.add attr, 'already exists' if Sprint.send("find_by_#{attr}".to_sym, value)
  end
  
  validate :start_date_before_end_date
  validate :sprint_duration_of_one_or_two_weeks
  
  before_save :set_name
  
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
  
  def self.with_open_stories
    sql =<<-EOSQL
      select distinct(sprint_name)
      from issues
      left join issue_statuses on issues.status_id = issue_statuses.id
      left join trackers on issues.tracker_id = trackers.id
      where issue_statuses.is_closed=0 AND trackers.name in ("Story", "Research", "Lab", "TechDebt")
    EOSQL
    
    Issue.find_by_sql(sql).map {|i| Sprint.find_by_name(i.sprint_name)}.sort_by(&:name)
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
  
  def duration
    (end_date - start_date).to_i + 1
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
  
  def sprint_day(date)
    return -1 unless start_date && end_date
    return -1 if date < start_date
    return 11 if date > end_date

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

private
  def start_date_before_end_date
    if end_date <= start_date
      errors.add(:start_date, 'must be before the end date')
    end
  end
  
  def sprint_duration_of_one_or_two_weeks
    if duration != 14 and duration != 7
      errors.add_to_base("Sprint duration must be one or two weeks")
    end
  end

  def set_name
    if end_date
      self.name = "#{end_date.strftime('%Y.%m.%d')}"
    end
  end  
end
