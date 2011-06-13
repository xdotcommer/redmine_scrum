class DeveloperStat < ActiveRecord::Base
  unloadable
  
  CLOSED_IDS = IssueStatus.find_all_by_is_closed(true).map(&:id)
  
  belongs_to  :sprint
  belongs_to  :user
  
  before_create   :denormalize_data
  before_save     :set_developer_stats
  
  def self.sprint_labels
    Sprint.with_developer_stats.commitable.past.map {|s| [s.id, s.name]}
  end
  
  def update_details_for(issue)
    return true if issue.is_story?
    return true unless issue.status_id_changed?
    
    self.story_reopens             += 1 if issue.status.is_reopened?
    self.pending_story_submissions += 1 if issue.status.is_pending?
    
    if issue.status.is_pending? && days_until_first_story_pending <= 0
      self.days_until_first_story_pending = sprint.sprint_day(Date.today)
    elsif issue.status.is_closed? && days_until_first_story_complete <= 0
      self.days_until_first_story_complete = sprint.sprint_day(Date.today) 
    end
  end
  
private
  def set_developer_stats
    issues = Issue.stories.for_sprint_and_developer(sprint_id, user_id)
    
    self.committed_stories = Commitment.count :conditions => {:sprint_id => sprint_id, :user_id => user_id}
    self.committed_points  = Commitment.sum(:story_points, :conditions => {:sprint_id => sprint_id, :user_id => user_id})
    self.completed_stories = issues.count :conditions => {:status_id => CLOSED_IDS}
    self.completed_points  = issues.sum(:story_points, :conditions => {:status_id => CLOSED_IDS})
    self.carryover_stories = committed_stories - completed_stories
    self.carryover_points  = committed_points - completed_points
  end

  def denormalize_data
    self.sprint_name = sprint.try(:name)
    self.user_name   = user.try(:name)
  end
end
