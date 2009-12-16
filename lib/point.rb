# Represents a two-dimensional point
class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x, @y = x, y
  end
  
  # Allow to do Point[x,y] instead of Point.new(x,y)
  def self.[](x,y)
    new(x,y)
  end

  def ==(other)
    other.class == Point && other.x == x && other.y == y
  end
  
  def inspect
    "(#{x},#{y})"
  end
  
  def to_a
    [@x, @y]
  end
  
  # Calculate the squared distance of this point to other
  def dist2(other)
    (@x - other.x)*(@x - other.x) + (@y - other.y)*(@y - other.y)
  end
end