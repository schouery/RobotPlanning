require 'lib/node'
# Represents a node that stores a segment in the trapezoidal map
class YNode < Node
  attr_accessor :segment
  
  def initialize(segment)
    @segment = segment.new_left_to_right
    super()
  end

  # If q is a point then returns the left child if the point in on the left of the segment
  # and the right child otherwise
  # If options[:segment] is true then looks if the segment lies above (left child)
  # or bellow (right child) the segment
  def child(q, options={})
    if options[:segment]
      if q.start == @segment.start
        if @segment.left(q.finish)
          @left_child
        else
          @right_child
        end
      else
        child q.start
      end
    else
      if @segment.left(q)
        @left_child
      elsif @segment.right(q)
        @right_child
      else
        nil
      end
    end
  end

  def ==(other)
    other.class == YNode && @segment == other.segment
  end
  
  def inspect
    "YNode: #{@segment.inspect}"
  end
  
  #Draws the segment
  def draw(drawer)
    @segment.draw(drawer)
  end
  
end