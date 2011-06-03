class BurndownFlot < Flot
  def self.line(canvas = nil, &block)
    flot = self.new(canvas, &block)
    flot.lines
    flot.points
    flot
  end
  
  def self.stacked_bar(canvas = nil, &block)
    flot = self.new(canvas, &block)
    flot.options[:series] = {:stack => 0, :bars => {:show => true, :barWidth => 0.5, :align => "center"}}
    flot
  end
  
  def initialize(canvas = nil,  &block)
    @options ||= {}
    xaxis :min => 0, :ticks => Burndown.day_labels, :max => 9
    yaxis :min => 0, :tickSize => 1, :tickDecimals => 0, :autoscaleMargin => nil
    grid :hoverable => true
    super(canvas, {}, &block)
  end
end