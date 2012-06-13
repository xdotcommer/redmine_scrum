class StatusBoard
  attr_accessor :status, :issues, :stories, :bugs
  
  def initialize(status, issues)
    self.status = status
    self.stories = issues.select { |s| s.status.name == status && Sprint::STORY_TRACKERS.include?(s.tracker) }
    self.bugs = issues.select { |s| s.status.name == status && Sprint::BUG_TRACKERS.include?(s.tracker) }
  end
end