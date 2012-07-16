class Burndown::Day
  attr_accessor :sprint_day, :pending, :open, :reopens, :sprint
  
  DAYS = %(Mon Tue Wed Thu Fri)
  
  def initialize(sprint, sprint_day)
    @pending = @open = @reopens = 0
    
    self.sprint_day = sprint_day
  end
  
  def sprint_day=(day)
    @sprint_day = day
  end
  
  def clear_data
    @open = @pending = @reopens = nil
  end
  
  def display_reopens
    if @reopens == 0 || @reopens.nil? || @open.nil? || @pending.nil?
      nil
    else
      @reopens - @open - @pending
    end
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