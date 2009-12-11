require 'lib/node'
class XNode < Node
  attr_reader :point

  def initialize(point)
    @point = point
  end

  def child(q, options={})
    q = q.start if(options[:segment])
    if q.x < @point.x
      @left_child
    else
      @right_child
    end
  end

  def ==(other)
    @point == other.point
  end

  def inspect
    "XNode: #{@point.inspect}"
  end

end
