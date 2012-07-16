class Burndown::Day
  attr_accessor :sprint_day, :pending, :open, :reopens, :starting_index
  
  DAYS = %(Mon Tue Wed Thu Fri)
  
  def initialize(sprint, sprint_day)
    @pending = @open = @reopens = 0
    
    self.starting_index = sprint.try(:starting_index)
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
    return nil unless starting_index
    
    (starting_index + sprint_day - 1) % 5
  end
  
  def day_of_week
    return nil unless starting_index
    
    Sprint::DAYS[day_of_week_index]
  end
end