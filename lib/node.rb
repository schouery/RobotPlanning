class Node
  attr_accessor :left_child, :right_child, :parent
  attr_reader :left_child, :right_child

  def left_child=(c)
    @left_child = c
    c.parent = self
  end

  def right_child=(c)
    @right_child = c
    c.parent = self
  end
  
  def children=(c)
    self.left_child = c[0]
    self.right_child = c[1]
  end

  def children
    [left_child, right_child]
  end

end