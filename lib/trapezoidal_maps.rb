class SearchStructure
  attr_accessor :root
  
  def initialize(root = nil)
    @root = root
  end
  
  def find(point)
    node = root
    while(node.class != TrapezoidNode)
      node = node.child(point)
    end
    node
  end

end

class Node
  attr_accessor :left_child, :right_child, :parent
end

class XNode < Node

  def initialize(point)
    @point = point
  end
  
  def child(q)
    if q[0] < @point[0]
      @left_child
    elsif q[0] > @point[0]
      @right_child
    else
      nil
    end
  end
  
end

class YNode < Node
  
  def initialize(a,b)
    if(a[0] < b[0] || a[1] < b[1])
      @a, @b = a, b
    else
      @a, @b = b, a
    end
  end
  
  def child(q)
    if left(@a,@b,q)
      @left_child
    elsif right(@a,@b,q)
      @right_child
    else
      nil
    end
  end
  
end

class TrapezoidNode < Node
end