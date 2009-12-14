require 'lib/node'

class TrapezoidNode < Node
  attr_reader :trapezoid, :vertice
  attr_accessor :left_neighbours, :right_neighbours, :left_vertices, :right_vertices
  
  def initialize(options={})
    @trapezoid = Trapezoid.new(options)
    @left_neighbours = []
    @right_neighbours = []
    @left_vertices = []
    @right_vertices = []
    super()
  end

  def ==(other)
    @trapezoid == other.trapezoid
  end  
  
  def inspect
    "TrapezoidNode:\n#{@trapezoid.inspect}"
  end
  
  def neighbours
    [@left_neighbours, @right_neighbours]
  end
  
  def neighbours=(n)
    @left_neighbours, @right_neighbours = n[0], n[1]
  end
  
  def next_neighbour(segment)
    @right_neighbours.find do |n|
      segment.left(n.trapezoid.top_left_corner) && segment.right(n.trapezoid.bottom_left_corner)
    end
  end
  
  def split_neighbours(segment, side)
    bottom, top = [], []
    neighbour(side).each do |n|
      point = side == :right ? n.trapezoid.bottom_left_corner : n.trapezoid.bottom_right_corner
      if segment.left point
        top << n
      else
        bottom << n
      end
    end
    # bottom.shift
    [bottom, top]
  end
  
  def correct_neighbours(cell, side)
    otherside = (side == :right ? :left : :right)
    neighbour(side).each do |n|
      list = (side == :right ? n.left_neighbours : n.right_neighbours)
      i = n.neighbour(otherside).index(cell)
      n.neighbour(otherside)[i] = self if i
    end
  end
  
  def neighbour(side)
    side == :right ? @right_neighbours : @left_neighbours
  end
  
  def draw(drawer)
    @trapezoid.draw(drawer)
  end
  
  def create_star(graph)
    return if @vertice
    @vertice = Graph::Vertice.new(@trapezoid.center)
    graph.add_vertice(@vertice)
    x = @trapezoid.leftp.x
    top = @trapezoid.top_left_corner.y
    @left_vertices = []
    @left_neighbours.each do |n|
      bottom = [n.trapezoid.bottom_right_corner.y, @trapezoid.bottom_left_corner.y].max
      top = [n.trapezoid.top_right_corner.y, @trapezoid.top_left_corner.y].min
      y = (bottom + top) / 2
  
      #LENTO - Precisa de referencia duplicada
      i = n.right_neighbours.index(self)
      # if i && n.right_vertices[i]
      if n.right_vertices[i]
        v = n.right_vertices[i]
      else
        v = Graph::Vertice.new(Point[x,y])
        graph.add_vertice(v) # so ocorre se ja nao existir
      end
      graph.add_edge(@vertice, v)
      @left_vertices << v
    end

    x = @trapezoid.rightp.x
    @right_vertices = []
    
    @right_neighbours.each do |n|
      bottom = [n.trapezoid.bottom_left_corner.y, @trapezoid.bottom_right_corner.y].max
      top = [n.trapezoid.top_left_corner.y, @trapezoid.top_right_corner.y].min
      y = (bottom + top) / 2

      #LENTO - Precisa de referencia duplicada
      i = n.left_neighbours.index(self)
      if n.left_vertices[i]
        v = n.left_vertices[i]
      else
        v = Graph::Vertice.new(Point[x,y])
        graph.add_vertice(v) # so ocorre se ja nao existir
      end

      graph.add_edge(@vertice, v)
      @right_vertices << v
    end
    
  end
  
end