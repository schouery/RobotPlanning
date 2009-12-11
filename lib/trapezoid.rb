class Trapezoid
  attr_accessor :leftp, :rightp, :top, :bottom
  
  def initialize(options = {})
    @leftp = options[:leftp]
    @rightp = options[:rightp]
    @top = options[:top].new_left_to_right if options[:top]
    @bottom = options[:bottom].new_left_to_right if options[:bottom]
  end
  
  def ==(other)
    (other.leftp == @leftp) && (other.rightp == @rightp) && (other.top == @top) && (other.bottom == @bottom)
  end
  
end