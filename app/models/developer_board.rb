class DeveloperBoard
  attr_accessor :name, :status_boards
  
  def initialize(name, issues)
    self.name = name
    self.status_boards = []

    Scrumboard::STATUSES.each do |status|
      status_boards << StatusBoard.new(status, issues.select {|s| s.assigned_to.login == name})
    end
  end
end