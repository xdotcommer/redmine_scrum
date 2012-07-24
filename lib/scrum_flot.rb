module ScrumFlot
  def line(canvas = nil, &block)
    flot = new(canvas, &block)
    flot.lines
    flot.points
    flot
  end
  
  def area(canvas = nil, &block)
    flot = new(canvas, &block)
    flot.options[:series] = {:stack => 0, :lines => {:show => true, :fill => true, :points => true}}
    flot
  end

  def bar(canvas = nil, &block)
    flot = new(canvas, &block)
    flot.options[:series] = {:bars => {:show => true, :barWidth => 0.5, :align => "center"}}
    flot
  end

  def stacked_bar(canvas = nil, &block)
    flot = new(canvas, &block)
    flot.options[:series] = {:stack => true, :bars => {:show => true, :barWidth => 0.5, :align => "center", :stack => true}}
    flot
  end
end