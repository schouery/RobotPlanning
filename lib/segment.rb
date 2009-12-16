# Represents a segment
class Segment
  attr_accessor :start, :finish

  #Receive the points that marks the start and finish of the segment
  def initialize(start, finish)
    @start, @finish = start, finish
  end
  
  def ==(other)
    other.class == Segment && other.start == @start && other.finish == @finish
  end
  
  # This method allows to do Segment[p1,p2] instead of Segment.new(p1,p2)
  def self.[](p1,p2)
    new(p1,p2)
  end
  
  # Create a new segment that is left to right orienteded
  def new_left_to_right
    if @start.x < @finish.x || (@start.x == @finish.x && @start.y < @finish.y)
      Segment.new(@start, @finish)
    else
      Segment.new(@finish, @start)
    end
  end
    
  # Test if a point is on the left of the segment
  def left(c)
    area2(c) > 0
  end

  # Test if a point is on the right of the segment
  def right(c)
    area2(c) < 0
  end

  # Test if a point is collinear with the segment
  def collinear(c)
    area2(c) == 0
  end

  # calculare signalled area of the triangle start, finish, c
  def area2(c)
    (@finish.x - @start.x)*(c.y - @start.y) - (c.x - @start.x)*(@finish.y - @start.y)
  end
  
  #Allow s[0] (returns start) and s[1] (returns finish)
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
  
  #Find the projection of point in this segment with the x-coord fixed
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
  
  #Draw this segment
  def draw(drawer)
    drawer.draw_segment(self)
  end
end