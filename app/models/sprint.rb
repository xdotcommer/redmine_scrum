class Sprint < ActiveRecord::Base
  unloadable

  STORY_TRACKERS  = ["Story", "Systems", "TechDebt"].map {|type| Tracker.find_by_name(type).id}
  BUG_TRACKERS    = ["Bug"].map {|type| Tracker.find_by_name(type).id}
  CLOSED_STATUSES = IssueStatus.find_all_by_is_closed(true).map(&:id)
  OPEN_STATUSES   = IssueStatus.find_all_by_is_closed(false).map(&:id)
  
  QA_STATUSES     = ["Needed", "Not Needed", "Succeeded", "Failed"]
  
  has_many  :issues
  has_many  :commitments
  has_many  :sprint_histories
  
  named_scope :recent, lambda { {:conditions => ["end_date >= ? OR name='Backlog' OR name='Icebox'", 14.days.ago], :order => 'name ASC' } }
  
  validates_each :start_date, :end_date, :on => :create do |record, attr, value|
    record.errors.add attr, 'already exists' if Sprint.send("find_by_#{attr}".to_sym, value)
  end
  
  validate :start_date_before_end_date
  validate :sprint_duration_of_one_or_two_weeks
  
  before_save :set_name
  
  belongs_to  :version

  def self.create_defaults
    if count == 0
      ['Backlog', 'Icebox'].each do |name|
        new(:name => name).save(false)
      end
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
    issues.count(:conditions => {:tracker_id => STORY_TRACKERS})
  end
  
  def open_story_count
    issues.count(:conditions => {:tracker_id => STORY_TRACKERS, :status_id => OPEN_STATUSES})
  end
  
  def closed_story_count
    issues.count(:conditions => {:tracker_id => STORY_TRACKERS, :status_id => CLOSED_STATUSES})
  end
  
  def open_bug_count
    issues.count(:conditions => {:tracker_id => BUG_TRACKERS, :status_id => OPEN_STATUSES})
  end
  
  def closed_bug_count
    issues.count(:conditions => {:tracker_id => BUG_TRACKERS, :status_id => CLOSED_STATUSES})
  end
  
  def bug_count
    issues.count(:conditions => {:tracker_id => BUG_TRACKERS})
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
