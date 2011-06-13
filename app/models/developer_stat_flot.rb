class DeveloperStatFlot < Flot
  extend ScrumFlot

  def initialize(canvas = nil,  &block)
    @options ||= {}
    xaxis :ticks => DeveloperStat.sprint_labels
    yaxis :min => 0, :tickDecimals => 0
    grid :hoverable => true
    super(canvas, {}, &block)
  end
end