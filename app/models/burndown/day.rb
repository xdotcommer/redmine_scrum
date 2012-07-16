class Burndown::Day
  attr_accessor :sprint_day, :pending, :open, :sprint
  
  DAYS = %(Mon Tue Wed Thu Fri)
  
  def initialize(sprint, sprint_day)
    @pending = @open = 0
    # if sprint_day == 0
    #   @open = sprint.committed_points
    # else
    #   @open = 0
    # end
    
    self.sprint_day = sprint_day
  end
  
  def sprint_day=(day)
    @sprint_day = day
  end
  
  def day_of_week_index
    return nil unless sprint && sprint.starting_index
    
    (sprint.starting_index + sprint_day) % 5
  end
  
  def day_of_week
    return nil unless sprint && sprint.starting_day
    
    Sprint::DAYS.index(day_of_week_index)
  end
end