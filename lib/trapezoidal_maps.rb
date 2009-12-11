require "lib/trapezoid"
require 'lib/node'
require 'lib/xnode'
require 'lib/ynode'
require 'lib/trapezoid_node'

class SearchStructure
  attr_reader :root
  
  def initialize(root = nil)
    @root = root
  end

  def find(info, options={})
    node = root
    while(node.class != TrapezoidNode)
      node = node.child(info, options)
    end
    node
  end

  def self.new_from_bounding_box(s1, s2, s3, s4)
    SearchStructure.new(TrapezoidNode.new(:leftp => s1.start, :rightp => s1.finish, :bottom => s1, :top => s3))
  end

  def add(segment)
    cell = find(segment, :segment => true)
    trapezoid = cell.trapezoid

    # for only ony trapezoid
    pi = XNode.new(segment.start)
    qi = XNode.new(segment.finish)
    si = YNode.new(segment)
    less_slope = (segment.start == trapezoid.bottom.start) || (segment.finish == trapezoid.top.finish)
    left_collision = (segment.start == trapezoid.leftp)
    right_collision = (segment.finish == trapezoid.rightp)
    
    a =  if left_collision
      cell.left_neighbours[0]
    else
      TrapezoidNode.new(:leftp => trapezoid.leftp, :rightp => segment.start, :top => trapezoid.top, :bottom => trapezoid.bottom)
    end
    
    b =  if right_collision
      cell.right_neighbours[0]
    else
      TrapezoidNode.new(:leftp => segment.finish, :rightp => trapezoid.rightp, :top => trapezoid.top, :bottom => trapezoid.bottom)
    end
    
    c = TrapezoidNode.new(:leftp => segment.start, :rightp => segment.finish, :top => trapezoid.top, :bottom => segment) 
    d = TrapezoidNode.new(:leftp => segment.start, :rightp => segment.finish, :top => segment, :bottom => trapezoid.bottom)
    
    pi.children = [a, qi]
    qi.children = [si,b]
    si.children = [c,d]
    parent = cell.parent
    
    if(parent.nil?)
      @root = pi
    elsif(parent.left_child == cell)
      parent.left_child = pi
    else
      parent.right_child = pi
    end
        
    a.neighbours = [cell.left_neighbours, []]
    a.right_neighbours << c unless left_collision && !less_slope
    a.right_neighbours << d unless left_collision && less_slope
    
    b.neighbours = [[],cell.right_neighbours]
    b.left_neighbours << c unless right_collision && less_slope
    b.left_neighbours << d unless right_collision && !less_slope
    
    c.left_neighbours << a unless left_collision && !less_slope
    c.right_neighbours << b unless right_collision && less_slope
    
    d.left_neighbours << a unless left_collision && less_slope
    d.right_neighbours << b unless right_collision && !less_slope
    
  end

  def root=(p)
    @root = p
    p.parent = nil
  end

end