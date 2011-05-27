class Burndown < ActiveRecord::Base
  unloadable

  FIELD_PREFIXES  = %w(open pending invalid complete verified duplicate wont reopened)
  STATUSES        = IssueStatus.all
  NAMES_TO_FIELDS = {
    "Open"             => FIELD_PREFIXES[0],
    "Pending Approval" => FIELD_PREFIXES[1],
    "Invalid"          => FIELD_PREFIXES[2],
    "Complete"         => FIELD_PREFIXES[3],
    "Verified Invalid" => FIELD_PREFIXES[4],
    "Duplicate"        => FIELD_PREFIXES[5],
    "Won't Fix"        => FIELD_PREFIXES[6],
    "Reopened"         => FIELD_PREFIXES[7]
  }
  
  def self.field_for_status_id(id)
    NAMES_TO_FIELDS[ name_for_status_id(id) ]
  end

  def self.name_for_status_id(id)
    STATUSES.detect {|s| s.id == id}.name
  end
  
  def self.status_id_for_prefix(prefix)
    STATUSES.detect {|s| s.name == NAMES_TO_FIELDS.invert[prefix]}.id
  end
  
  # Step 1: Set first snapshot from the commitment & issues themselves
  # Step 2: Set update the snapshots based on journal entries that have status / qa changes
  # Step 3: Close out totals at the end of the sprint?
  
  # Developer Charts:
  # Burndown: daily open, pending, and closed stories by developer (in sprint)
  # Bugs: assigned, open, pending, and closed by developer (in sprint)
  # Reopens: Story and Bug reopen counts by developer / sprint (not daily)
  # Velocity: Developer committed and actuals by sprint (compleition %, avg velocity and consistency)
  # Carryover stories and story points by developer (and then the average per active sprint)
  # 
  # QA Charts:
  # Bugs resolution: closed, duplicate, invalid, won't fix counts by QA in sprint (not daily)
  # Bug found by priority: each priority - count of bugs by QA in sprint (not daily)
  # Graph of bugs over time (daily) by priority (stacked graph)
  # Graph of bugs over time (daily) by resolution (include open)
  
  def self.log_from_issue(issue)
    raise issue.inspect
  end
  
  def self.log_from_journal(journal)
    return unless journal.details.any? {|detail| detail.status_change? || detail.qa_change? }
  
    if Sprint::STORY_TRACKERS.include? journal.issue.tracker_id
      Burndown::Story.log(Date.yesterday, journal.issue.sprint, journal.issue.assigned_to)
    elsif Sprint::BUG_TRACKERS.include? journal.issue.tracker_id
      # Burndown::Bug.log(Date.yesterday, journal.issue.sprint, journal.issue.assigned_to)
    end
  end
end
