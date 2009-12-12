class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x, @y = x, y
  end

  def self.[](x,y)
    new(x,y)
  end

  def ==(other)
    other.class == Point && other.x == x && other.y == y
  end
  
  def inspect
    "(#{x},#{y})"
  end
end