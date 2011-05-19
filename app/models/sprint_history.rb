class SprintHistory < ActiveRecord::Base
  unloadable
  PHASES = ["before", "planning", "mid", "after"]
  BEFORE, PLANNING, MID_ITERATION, AFTER = PHASES
  
  # SET CLASSES, ETC.
  belongs_to  :issue
  belongs_to  :tracker
  belongs_to  :status
  belongs_to  :sprint
  belongs_to  :estimation
  belongs_to  :assigned_to
  belongs_to  :author
  belongs_to  :category
  belongs_to  :priority
  
  # TODO: HOW TO GET THE CHANGED BY ???
  def self.create_from_issue(issue)
    #    story.defect_count = 
    #    story.comment_count = 
    #    story.ac_count = 
    
    sprint_history = SprintHistory.new({
      :issue_id       => issue.id,
      :sprint_id      => issue.sprint_id,
      :tracker_id     => issue.tracker_id,
      :status_id      => issue.status_id,
      :assigned_to_id => issue.assigned_to_id,
      :category_id    => issue.category_id,
      :estimation_id  => issue.estimation_id,
      :author_id      => issue.author_id,
      :priority_id    => issue.priority_id,
      :version_id     => issue.fixed_version_id,
      :developer      => issue.assigned_to.try(:name),
      :category_name  => issue.category.try(:name),
      :status_name    => issue.status.try(:name),
      :tracker_name   => issue.tracker.try(:name),
      :sprint_name    => issue.sprint.try(:name),
      :version_name   => issue.fixed_version.try(:name),
      :priority_name  => issue.priority.try(:name),
      :qa_status      => issue.qa,
      :story_points   => issue.story_points
    })
    
    
    sprint_history.determine_phase
    sprint_history.save!
  end
  
  def determine_phase
    return true unless sprint
    
    if ! sprint.commitable? || Date.today < sprint.start_date
      self.phase = BEFORE
    elsif Date.today == sprint.start_date
      self.phase = PLANNING
    elsif Date.today <= sprint.end_date
      self.phase = MID_ITERATION
    elsif Date.today > sprint.end_date
      self.phase = AFTER
    end
  end
end
