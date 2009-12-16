require 'lib/node'
# Represents a node that stores a point in the trapezoidal map
class XNode < Node
  attr_reader :point

  def initialize(point)
    @point = point
    super()
  end

  # Returns the left child if q (or the left point of q, if q is a segment)
  # lies on the left of the point, and the right child otherwise
  # If q is a segment, you should set options[:segment]
  def child(q, options={})
    q = q.start if(options[:segment])
    if q.x < @point.x
      @left_child
    else
      @right_child
    end
  end

  def ==(other)
    other.class == XNode && @point == other.point
  end

  def inspect
    "XNode: #{@point.inspect}"
  end

end
