require 'lib/trapezoid'
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
    segment = segment.new_left_to_right
    cell = find(segment, :segment => true)
    trapezoid = cell.trapezoid
    si = YNode.new(segment)
    last = trapezoid.rightp.x >= segment.finish.x 
    right = last ? segment.finish : trapezoid.rightp
    top = split(segment.start, right, segment, trapezoid, :top)
    bottom = split(segment.start, right, segment, trapezoid, :bottom)
    si.children = [top,bottom]
    if last
      left_collision = (trapezoid.leftp.x == segment.start.x)
      right_collision = (segment.finish.x == trapezoid.rightp.x)      
      if !left_collision    
        pi = XNode.new(segment.start)
        left = TrapezoidNode.new(:leftp => trapezoid.leftp,
                                 :rightp => segment.start,
                                 :top => trapezoid.top,
                                 :bottom => trapezoid.bottom)    
        update_parents(cell, pi)
        make_corner_neighbours(left, top, bottom, cell, :left)  
      end
        if !right_collision
          right = TrapezoidNode.new(:leftp => segment.finish,
                              :rightp => trapezoid.rightp,
                              :top => trapezoid.top,
                              :bottom => trapezoid.bottom)
          qi = XNode.new(segment.finish)
          qi.children = [si, right]
          make_corner_neighbours(right, top, bottom, cell, :right)
        end
        if !left_collision
          if !right_collision
            pi.children = [left, qi]
          else
            pi.children = [left, si]
            if segment.finish == trapezoid.bottom_right_corner
              top.right_neighbours = cell.right_neighbours
              top.correct_neighbours(cell, :right)
            elsif segment.finish == trapezoid.top_right_corner
              bottom.right_neighbours = cell.right_neighbours
              bottom.correct_neighbours(cell, :right)
            else
              #TODO
              cell.right_neighbours.each do |r|
                if r.trapezoid.bottom_left_corner.y >= segment.finish.y
                  top.right_neighbours << l
                else
                  bottom.right_neighbours << l
                end
              end
              top.correct_neighbours(cell, :right)
              bottom.correct_neighbours(cell, :right)
            end
          end
        else
          if segment.start == trapezoid.bottom_left_corner          
            top.left_neighbours = cell.left_neighbours
            top.correct_neighbours(cell, :left)
          elsif segment.start == trapezoid.top_left_corner
            bottom.left_neighbours = cell.left_neighbours
            bottom.correct_neighbours(cell, :left)        
          else
            # TODO
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
          update_parents(cell,qi)
        end
      return
    end
    if trapezoid.leftp.x == segment.start.x  
      update_parents(cell, si)
      make_neighbours(bottom, top, cell, segment, :left)
    else    
      pi = XNode.new(segment.start)
      left = TrapezoidNode.new(:leftp => trapezoid.leftp,
                               :rightp => segment.start,
                               :top => trapezoid.top,
                               :bottom => trapezoid.bottom)    
      pi.children = [left, si]
      update_parents(cell, pi)
      make_corner_neighbours(left, top, bottom, cell, :left)
    end
    make_neighbours(bottom, top, cell, segment, :right)
    cell = cell.next_neighbour(segment)    
    while(!cell.nil? && cell.trapezoid.leftp.x < segment.finish.x)
      trapezoid = cell.trapezoid
      last = trapezoid.rightp.x >= segment.finish.x
      right = last ? segment.finish : trapezoid.rightp
      si = YNode.new(segment)
      old_bottom, old_top = bottom, top
      bottom, top = merge(segment, trapezoid, bottom, top, right)
      make_left_neighbours(bottom, old_bottom, top, old_top, cell, segment)
      si.children = [top, bottom]
      if !last
        make_neighbours(bottom, top, cell, segment, :right)
        update_parents(cell, si)
      else
        if trapezoid.rightp.x == segment.finish.x
          update_parents(cell, si)
          make_neighbours(bottom, top, cell, segment, :right)
        else    
          right = TrapezoidNode.new(:leftp => segment.finish,
                              :rightp => trapezoid.rightp,
                              :top => trapezoid.top,
                              :bottom => trapezoid.bottom)
          qi = XNode.new(segment.finish)
          qi.children = [si, right]
          update_parents(cell, qi)
          make_corner_neighbours(right, top, bottom, cell, :right)
        end
      end
      cell = cell.next_neighbour(segment)
    end
  end

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

  def make_left_neighbours(bottom, old_bottom, top, old_top, cell, segment)
    if(old_bottom != bottom)
      bottom.left_neighbours = cell.split_neighbours(segment,:left)[0]
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

  def make_neighbours(bottom, top, cell, segment, side)
    bottom.right_neighbours, top.right_neighbours = cell.split_neighbours(segment, side)
    bottom.correct_neighbours(cell, side)
    top.correct_neighbours(cell, side)
  end

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

  def draw(drawer)
    recursive_draw(@root, drawer)
  end

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

  def create_graph
    g = Graph::AdjacencyListGraph.new
    recursive_create_graph(root, g)
    g
  end
  
  def recursive_create_graph(node, g)
    if node.class == TrapezoidNode
      node.create_star(g)
    else
      recursive_create_graph(node.left_child, g)
      recursive_create_graph(node.right_child, g)
    end
  end

end