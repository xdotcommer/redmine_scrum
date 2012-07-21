class SprintStat
  attr_accessor :start_date

  def initialize(start_date = nil)
    @start_date = start_date
  end

  def sprints
    Sprint.up_to_current_since(@start_date)
  end
end