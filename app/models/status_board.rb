class StatusBoard
  attr_accessor :status, :issues
  
  def initialize(status, issues)
    self.status = status
    self.issues = issues.select { |s| s.status.name == status }
  end
end