require 'lib/node'

class TrapezoidNode < Node
  attr_reader :trapezoid
  attr_accessor :left_neighbours, :right_neighbours
  
  def initialize(options={})
    @trapezoid = Trapezoid.new(options)
    @left_neighbours = []
    @right_neighbours = []
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
    # andar por todos os right_neighbours, analisando se o segmento passa abaixo ou acima do ponto, leftp do trapezoid
    next_cell = @right_neighbours[0]
    @right_neighbours.each do |n|
        next_cell = n if segment.left(n.trapezoid.leftp)
    end
    next_cell
  end
  
  def split_neighbours(segment, side)
    bottom, top = [], []
    neighbour(side).each do |n|
      point = side == :right ? n.trapezoid.leftp : n.trapezoid.rightp
      if segment.left point
        top << n
      else
        bottom << n
      end
    end
    bottom.shift
    [bottom, top]
  end
  
  def correct_neighbours(cell, side)
    otherside = (side == :right ? :left : :right)
    neighbour(side).each do |n|
      list = (side == :right ? n.left_neighbours : n.right_neighbours)
      i = n.neighbour(otherside).index(cell)
      n.neighbour(otherside)[i] = self
    end
  end
  
  def neighbour(side)
    side == :right ? @right_neighbours : @left_neighbours
  end
  
end