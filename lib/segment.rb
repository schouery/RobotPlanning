class Segment
  attr_accessor :start, :finish

  def initialize(start, finish)
    @start, @finish = start, finish
  end
  
  def ==(other)
    other.class == Segment && other.start == @start && other.finish == @finish
  end
  
  def self.[](p1,p2)
    new(p1,p2)
  end
  
  def new_left_to_right
    if @start.x < @finish.x || (@start.x == @finish.x && @start.y < @finish.y)
      Segment.new(@start, @finish)
    else
      Segment.new(@finish, @start)
    end
  end
    
  def left(c)
    (@finish.x - @start.x)*(c.y - @start.y) - (c.x - @start.x)*(@finish.y - @start.y) > 0
  end

  def right(c)
    (@finish.x - @start.x)*(c.y - @start.y) - (c.x - @start.x)*(@finish.y - @start.y) < 0
  end
  
  def [](index)
    if index == 0
      @start
    elsif index == 1
      @finish
    else
      nil
    end
  end
  
  def inspect
    "[#{@start.inspect}, #{@finish.inspect}]"
  end
end