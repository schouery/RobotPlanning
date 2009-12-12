class Node
  attr_accessor :left_child, :right_child
  attr_reader :left_child, :right_child
  attr_accessor :parents

  def left_child=(c)
    @left_child = c
    c.parents << self
  end

  def right_child=(c)
    @right_child = c
    c.parents << self
  end
  
  def children=(c)
    self.left_child = c[0]
    self.right_child = c[1]
  end

  def children
    [left_child, right_child]
  end

  def initialize
    @parents = []
  end

end