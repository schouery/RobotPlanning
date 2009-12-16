require 'lib/trapezoid'
require 'lib/node'
require 'lib/xnode'
require 'lib/ynode'
require 'lib/trapezoid_node'

# Search Structure generated from a trapeozidal map
class SearchStructure
  attr_reader :root, :new_trapezoids
  
  def initialize(root = nil)
    @root = root
  end

  # Search for a point or segment
  def find(info, options={})
    node = @root
    while(node.class != TrapezoidNode)
      node = node.child(info, options)
    end
    node
  end

  # Create a new SearchStructure from a bounding box
  def self.new_from_bounding_box(s1, s2, s3, s4)
    SearchStructure.new(TrapezoidNode.new(:leftp => s1.start, :rightp => s1.finish, :bottom => s1, :top => s3))
  end
  
  # Used when the segment added cross only one trapezoid
  def solve_for_one(segment, cell, trapezoid, si, right, top, bottom)
    left_collision = (trapezoid.leftp.x == segment.start.x)
    right_collision = (segment.finish.x == trapezoid.rightp.x)      
    if !left_collision    
      pi = XNode.new(segment.start)
      left = TrapezoidNode.new(:leftp => trapezoid.leftp,
                               :rightp => segment.start,
                               :top => trapezoid.top,
                               :bottom => trapezoid.bottom)    
      @new_trapezoids << left
      update_parents(cell, pi)
      make_corner_neighbours(left, top, bottom, cell, :left)  
    end
      if !right_collision
        right = TrapezoidNode.new(:leftp => segment.finish,
                            :rightp => trapezoid.rightp,
                            :top => trapezoid.top,
                            :bottom => trapezoid.bottom)
        @new_trapezoids << right
        qi = XNode.new(segment.finish)
        qi.children = [si, right]
        make_corner_neighbours(right, top, bottom, cell, :right)
      end
      if !left_collision
        if !right_collision
          pi.children = [left, qi]
        else
          pi.children = [left, si]
          correct_neighbours_for_right_collision(segment, trapezoid, top, bottom, cell)
        end
      else
        if right_collision
          update_parents(cell,si)
          correct_neighbours_for_left_collision(segment, trapezoid, top, bottom, cell)
          correct_neighbours_for_right_collision(segment, trapezoid, top, bottom, cell)
        else
          update_parents(cell,qi)
          correct_neighbours_for_left_collision(segment, trapezoid, top, bottom, cell)
        end
      end    
  end
  
  # Generates a list os trapezoid which will be crossed by segment, used for animation
  def update_list(segment)
    list = []
    cell = find(segment, :segment => true)
    list << cell.trapezoid
    last = cell.trapezoid.rightp.x >= segment.finish.x 
    cell = cell.next_neighbour(segment)
    while(!last && !cell.nil? && cell.trapezoid.leftp.x < segment.finish.x)
      list << cell.trapezoid
      cell = cell.next_neighbour(segment)
    end
    list
  end

  # Add a new segment to the structure, spliting the current trapezoids and updates
  # new_trapezoids, allowing to draw which trapezoids are recently created
  def add(segment)
    @new_trapezoids = []    
    segment = segment.new_left_to_right
    cell = find(segment, :segment => true)
    trapezoid = cell.trapezoid
    si = YNode.new(segment)
    last = trapezoid.rightp.x >= segment.finish.x 
    right = last ? segment.finish : trapezoid.rightp
    top = split(segment.start, right, segment, trapezoid, :top)
    bottom = split(segment.start, right, segment, trapezoid, :bottom)
    @new_trapezoids << top
    @new_trapezoids << bottom
    si.children = [top,bottom]
    if last
      solve_for_one(segment, cell, trapezoid, si, right, top, bottom)
      return
    end
    if trapezoid.leftp.x == segment.start.x  
      update_parents(cell, si)
      correct_neighbours_for_left_collision(segment, trapezoid, top, bottom, cell)
    else
      pi = XNode.new(segment.start)
      left = TrapezoidNode.new(:leftp => trapezoid.leftp,
                               :rightp => segment.start,
                               :top => trapezoid.top,
                               :bottom => trapezoid.bottom)    
      @new_trapezoids << left
      pi.children = [left, si]
      update_parents(cell, pi)
      make_corner_neighbours(left, top, bottom, cell, :left)
    end
    make_neighbours(bottom, top, cell, segment, :right, true)
    cell = cell.next_neighbour(segment)
    while(!cell.nil? && cell.trapezoid.leftp.x < segment.finish.x)
      trapezoid = cell.trapezoid
      last = trapezoid.rightp.x >= segment.finish.x
      right = last ? segment.finish : trapezoid.rightp
      si = YNode.new(segment)
      old_bottom, old_top = bottom, top
      bottom, top = merge(segment, trapezoid, bottom, top, right)
      @new_trapezoids << bottom if bottom != old_bottom
      @new_trapezoids << top if top != top
      make_left_neighbours(bottom, old_bottom, top, old_top, cell, segment)
      si.children = [top, bottom]
      if !last
        make_neighbours(bottom, top, cell, segment, :right, true)
        update_parents(cell, si)
      else
        if trapezoid.rightp.x == segment.finish.x
          update_parents(cell, si)
          correct_neighbours_for_right_collision(segment, trapezoid, top, bottom, cell)
        else    
          right = TrapezoidNode.new(:leftp => segment.finish,
                              :rightp => trapezoid.rightp,
                              :top => trapezoid.top,
                              :bottom => trapezoid.bottom)
          @new_trapezoids << right
          qi = XNode.new(segment.finish)
          qi.children = [si, right]
          update_parents(cell, qi)
          make_corner_neighbours(right, top, bottom, cell, :right)
        end
      end
      cell = cell.next_neighbour(segment)
    end
  end

  # Updates the parents of cell, switching it to new_child
  def update_parents(cell, new_child)
    if cell.parents.empty?
      @root = new_child
    else
      cell.parents.each do |p|
        if p.left_child == cell
          p.left_child = new_child
        else
          p.right_child = new_child
        end
      end
    end
  end

  # Splits the trapezoid
  # * left: the leftp of the new trapezoid
  # * right: the rightp of the new trapezoid
  # * segment: the segment doing the split
  # * trapezoid: the trapezoid being splitted
  # * side: :top or :bottom, depending which trapezoid is desired
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

  # Whenever we have multiple crossings, one of the new trapezoids have to be merged
  # with its left neighbour.
  # This method does that, merging the necessary one and creating the other that is not
  # goig to be merged.
  def merge(segment, trapezoid, bottom, top, right)
    if segment.left(trapezoid.leftp)
      top = split(trapezoid.leftp, right, segment, trapezoid, :top)
      bottom.trapezoid.rightp = right
    else
      bottom = split(trapezoid.leftp, right, segment, trapezoid, :bottom)
      top.trapezoid.rightp = right
    end 
    [bottom,top]
  end

  # Adjusts the left neighbours of top or bottom, depending which one made the merge
  # This one is used for merge purpouses only
  def make_left_neighbours(bottom, old_bottom, top, old_top, cell, segment)
    if(old_bottom != bottom)
      bottom.left_neighbours = cell.split_neighbours(segment,:left)[0]
      bottom.left_neighbours.shift
      bottom.correct_neighbours(cell, :left) 
      bottom.left_neighbours.unshift old_bottom
      old_bottom.right_neighbours.unshift bottom        
    else
      top.left_neighbours = cell.split_neighbours(segment,:left)[1]
      top.correct_neighbours(cell, :left)
      top.left_neighbours << old_top
      old_top.right_neighbours << top
    end
  end

  # Splits the cell neighbours for top and bottom
  def make_neighbours(bottom, top, cell, segment, side, shift_bottom = false)
    if side == :right
      bottom.right_neighbours, top.right_neighbours = cell.split_neighbours(segment, side)
      bottom.right_neighbours.shift if shift_bottom
    else
      bottom.left_neighbours, top.left_neighbours = cell.split_neighbours(segment, side)
      bottom.left_neighbours.shift if shift_bottom
    end
    bottom.correct_neighbours(cell, side)
    top.correct_neighbours(cell, side)
  end

  # Make corners neighbours, used in the first and last splits, when there is no left (or right)
  # collisions.
  def make_corner_neighbours(node, top, bottom, cell, side)
    if side == :left
      node.left_neighbours = cell.left_neighbours
      node.correct_neighbours(cell, :left)
      node.right_neighbours = [top,bottom]
      top.left_neighbours << node
      bottom.left_neighbours << node
    else
      node.right_neighbours = cell.right_neighbours
      node.correct_neighbours(cell, :right)
      node.left_neighbours = [top,bottom]
      top.right_neighbours << node
      bottom.right_neighbours << node
    end
  end

  # Draw the structure
  def draw(drawer)
    recursive_draw(@root, drawer)
  end

  # Used to draw the structure
  def recursive_draw(node, drawer)
    if node.class == YNode
      node.draw(drawer)
      recursive_draw(node.left_child, drawer)
      recursive_draw(node.right_child, drawer)
    elsif node.class == XNode
      recursive_draw(node.left_child, drawer)
      recursive_draw(node.right_child, drawer)
    else
      node.draw(drawer)
    end 
  end

  # Create the graph from the structure
  def create_graph
    g = Graph::AdjacencyListGraph.new
    recursive_create_graph(root, g)
    g
  end
  
  # Used to create the graph
  def recursive_create_graph(node, g)
    if node.class == TrapezoidNode
      node.create_star(g)
    else
      recursive_create_graph(node.left_child, g)
      recursive_create_graph(node.right_child, g)
    end
  end

  def correct_neighbours_for_right_collision(segment, trapezoid, top, bottom, cell)
    if segment.finish == trapezoid.bottom_right_corner
      top.right_neighbours = cell.right_neighbours
      top.correct_neighbours(cell, :right)
    elsif segment.finish == trapezoid.top_right_corner
      bottom.right_neighbours = cell.right_neighbours
      bottom.correct_neighbours(cell, :right)
    else
      cell.right_neighbours.each do |r|
        if r.trapezoid.bottom_left_corner.y >= segment.finish.y
          top.right_neighbours << r
        else
          bottom.right_neighbours << r
        end
      end
      top.correct_neighbours(cell, :right)
      bottom.correct_neighbours(cell, :right)
    end
  end
  
  def correct_neighbours_for_left_collision(segment, trapezoid, top, bottom, cell)
    if segment.start == trapezoid.bottom_left_corner
      top.left_neighbours = cell.left_neighbours
      top.correct_neighbours(cell, :left)
    elsif segment.start == trapezoid.top_left_corner
      bottom.left_neighbours = cell.left_neighbours
      bottom.correct_neighbours(cell, :left)        
    else
      cell.left_neighbours.each do |l|
        if l.trapezoid.bottom_right_corner.y >= segment.start.y
          top.left_neighbours << l
        else
          bottom.left_neighbours << l
        end
      end
      top.correct_neighbours(cell, :left)
      bottom.correct_neighbours(cell, :left)
    end
  end

end