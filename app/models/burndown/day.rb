class Burndown::Day
  attr_accessor :sprint_day, :pending, :open
  
  def initialize
    @pending = 0
    @open = 0
  end
end