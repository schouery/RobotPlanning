require 'lib/node'
class YNode < Node
  attr_accessor :segment
  
  def initialize(segment)
    @segment = segment.new_left_to_right
    super()
  end

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
  
  def draw(drawer)
    @segment.draw(drawer)
  end
  
end