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
    "TrapezoidNode: #{@trapezoid.inspect}"
  end
  
  def neighbours
    [@left_neighbours, @right_neighbours]
  end
  
  def neighbours=(n)
    @left_neighbours, @right_neighbours = n[0], n[1]
  end
  
end