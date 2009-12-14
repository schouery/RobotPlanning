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

  def collinear(c)
    (@finish.x - @start.x)*(c.y - @start.y) - (c.x - @start.x)*(@finish.y - @start.y) == 0
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
  
  def x_projection(point)
    x = point.x
    if start.x != finish.x
      y = (start.x*finish.y + x*start.y - x*finish.y - start.y*finish.x)/(start.x - finish.x)
    else
      return nil if point.x != start.x
      if point.y < start.y && point.y > finish.y || point.y > start.y && point.y < finish.y
        return point 
      elsif (point.y - start.y).abs < (point.y - finish.y).abs    
        y = start.y
      else
        y = finish.y
      end
    end
    Point[x,y]
  end
  
  def draw(drawer)
    drawer.draw_segment(self)
  end
end