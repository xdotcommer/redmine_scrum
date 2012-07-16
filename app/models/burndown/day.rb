class Burndown::Day
  attr_accessor :sprint_day, :pending, :open, :sprint
  
  DAYS = %(Mon Tue Wed Thu Fri)
  
  def initialize(sprint, sprint_day)
    self.pending = self.open = 0

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
  
  def update_totals
    devs.each do |dev|
      overall[i].pending += dev.pending_point_count
      overall[i].open += dev.open_point_count
    end
  end
end