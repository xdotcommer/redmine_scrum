class BurndownFlot < Flot
  extend ScrumFlot

  def initialize(sprint,  &block)
    @options ||= {}
    xaxis :min => 0, :ticks => sprint.day_labels, :max => sprint.duration
    yaxis :min => 0, :tickDecimals => 0
    grid :hoverable => true
    super("Burndown", {}, &block)
  end
end