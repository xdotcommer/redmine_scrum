class Scrumboard
  STATUSES = %w(Open Reopened Pending Complete)
  DEVELOPERS = %w(al amc archana lisap mattw mikecowden will dev_team)

  attr_accessor :sprint, :sprints_by_developer_and_status, :developer_boards
  
  def initialize(sprint)
    self.sprint = sprint
    self.sprints_by_developer_and_status = {}
    self.developer_boards = []
    
    
    DEVELOPERS.each do |login|
      if user = User.find_by_login(login)
        developer_boards << DeveloperBoard.new(login, @sprint.issues.select { |s| Sprint::STORY_TRACKERS.include?(s.tracker) })
      end
    end
  end
end