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
    node = @root
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

    if(segment.finish.x <= trapezoid.rightp.x)
      one_crossing(cell, trapezoid, segment)
    else
      more_crossings(cell, trapezoid, segment)
    end
  end

  def one_crossing(cell, trapezoid, segment)
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
    
    if(cell.parents.empty?)
      @root = pi
    else
      update_parents(cell, pi)
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

  def more_crossings(cell, trapezoid, segment)
    # Delta0
    pi = XNode.new(segment.start)
    si = YNode.new(segment)
    left = TrapezoidNode.new(:leftp => trapezoid.leftp,
                             :rightp => segment.start,
                             :top => trapezoid.top,
                             :bottom => trapezoid.bottom)    
    top = split(segment.start, trapezoid.rightp, segment, trapezoid, :top)
    bottom = split(segment.start, trapezoid.rightp, segment, trapezoid, :bottom)

    pi.children = [left, si]  
    si.children = [bottom, top]
    update_parents(cell, pi)
    
    left.left_neighbours = cell.left_neighbours
    left.right_neighbours = [top,bottom]
    top.left_neighbours = [left]
    bottom.left_neighbours = [left]
    
    bottom.right_neighbours, top.right_neighbours = cell.split_neighbours(segment, :right)

    bottom.correct_neighbours(cell, :right)
    top.correct_neighbours(cell, :right)
        
    # Delta i
    cell = cell.next_neighbour(segment)    
    trapezoid = cell.trapezoid
    while(trapezoid.rightp.x < segment.finish.x)
      si = YNode.new(segment)
      old_bottom = bottom
      old_top = top
      bottom, top = merge(segment, trapezoid, bottom, top, trapezoid.rightp)
      
      
      br, tr = cell.split_neighbours(segment,:right)
      bl, tl = cell.split_neighbours(segment,:left)
      
      if(old_bottom != bottom)
        old_bottom.right_neighbours.unshift bottom
        bottom.left_neighbours = bl
        bottom.correct_neighbours(cell, :left)      
        bottom.left_neighbours.unshift old_bottom        
      else
        old_top.right_neighbours << top
        top.left_neighbours = tl
        top.correct_neighbours(cell, :left)      
        top.left_neighbours << old_top
      end
      
      bottom.right_neighbours = br
      bottom.correct_neighbours(cell, :right)
      top.right_neighbours = tr
      top.correct_neighbours(cell, :right)
      
      si.children = [top,bottom]
      update_parents(cell, si)
      cell = cell.next_neighbour(segment)
      trapezoid = cell.trapezoid
    end
    
    # DeltaK
    si = YNode.new(segment)
    old_bottom, old_top = bottom, top
    bottom, top = merge(segment, trapezoid, bottom, top, segment.finish)

    bl, tl = cell.split_neighbours(segment,:left)

    if(old_bottom != bottom)
      old_bottom.right_neighbours.unshift bottom
      bottom.left_neighbours = bl
      bottom.correct_neighbours(cell, :left)      
      bottom.left_neighbours.unshift old_bottom        
    else
      old_top.right_neighbours << top
      top.left_neighbours = tl
      top.correct_neighbours(cell, :left)      
      top.left_neighbours << old_top
    end
        
    right = TrapezoidNode.new(:leftp => segment.finish,
                          :rightp => trapezoid.rightp,
                          :top => trapezoid.top,
                          :bottom => trapezoid.bottom)

    si.children = [top, bottom]
    
    qi = XNode.new(segment.finish)
    qi.children = [si, right]
    update_parents(cell, qi)

    top.right_neighbours = [right]
    bottom.right_neighbours = [right]
    right.left_neighbours = [top,bottom]
    right.right_neighbours = cell.right_neighbours
    
  end

  def update_parents(cell, new_child)
    cell.parents.each do |p|
      if p.left_child == cell
        p.left_child = new_child
      else
        p.right_child = new_child
      end
    end
  end

  def split(left, right, segment, trapezoid, side)
    if(side == :top)
      TrapezoidNode.new(:leftp => left,
                        :rightp => right,
                        :top => trapezoid.top,
                        :bottom => segment) 
    else
      TrapezoidNode.new(:leftp => left,
                        :rightp => right,
                        :top => segment,
                        :bottom => trapezoid.bottom)
    end
  end

  def merge(segment, trapezoid, bottom, top, right)
    if segment.left(trapezoid.leftp) #ponto está a acima, fazermos merge abaixo
      top = split(trapezoid.leftp, right, segment, trapezoid, :top)
      bottom.trapezoid.rightp = right
    else
      bottom = split(trapezoid.leftp, right, segment, trapezoid, :bottom)
      top.trapezoid.rightp = right
    end 
    [bottom,top]
  end

end