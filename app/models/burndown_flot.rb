class BurndownFlot < Flot
  extend ScrumFlot

  def initialize(sprint,  &block)
    @options ||= {}
    xaxis :min => 0, :ticks => sprint.day_labels, :max => 10
    yaxis :min => 0, :tickDecimals => 0
    grid :hoverable => true
    super("Burndown", {}, &block)
  end
end