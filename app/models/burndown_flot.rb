class BurndownFlot < Flot
  extend ScrumFlot

  def initialize(canvas = nil,  &block)
    @options ||= {}
    xaxis :min => 0, :ticks => Burndown.day_labels, :max => 10
    yaxis :min => 0, :tickDecimals => 0
    grid :hoverable => true
    super(canvas, {}, &block)
  end
end