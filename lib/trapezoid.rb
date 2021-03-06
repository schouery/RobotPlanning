# Represents a trapezoid
class Trapezoid
  attr_accessor :leftp, :rightp, :top, :bottom
  attr_reader :top_right_corner, :top_left_corner, :bottom_left_corner, :bottom_right_corner, :center
  
  # Setups the trapezoid
  # options[:leftp] the Point in the left of the trapezoid
  # options[:rightp] the Point in the right of the trapezoid
  # options[:top] the Segment in the top of the trapezoid
  # options[:bottom] the Segment in the top of the trapezoid
  def initialize(options = {})
    @leftp = options[:leftp] || Point[0,0]
    @rightp = options[:rightp] || Point[0,0]
    @top = options[:top].new_left_to_right if options[:top]
    @bottom = options[:bottom].new_left_to_right if options[:bottom]
    @top ||= Segment[Point[0,0], Point[0,0]]
    @bottom ||= Segment[Point[0,0], Point[0,0]]
    update
  end
  
  # Calculates the corners and the center, used for painting and
  # through the algoritm
  def update
    @top_left_corner = @top.x_projection(@leftp)
    @top_right_corner = @top.x_projection(@rightp)
    @bottom_left_corner = @bottom.x_projection(@leftp)
    @bottom_right_corner = @bottom.x_projection(@rightp)    
    @center = calculate_center 
  end
  
  def leftp=(p)
    @leftp = p
    update
  end
  
  def rightp=(p)
    @rightp = p
    update
  end
  
  def ==(other)
    (other.leftp == @leftp) && (other.rightp == @rightp) && (other.top == @top) && (other.bottom == @bottom)
  end
  
  def inspect
    "leftp: #{leftp.inspect})\n" +
    "rightp: #{rightp.inspect}\n" +
    "top: #{top.inspect}\n" +
    "bottom: #{bottom.inspect}\n"
  end
  
  # Draws the trapezoid
  def draw(drawer)
    drawer.draw_trapezoid(self)
  end
  
  # Calculate the "center" find the middle point of the segments that goes through the middle
  # of left and right sides
  def calculate_center
    p1 = Point[@leftp.x, (@top_left_corner.y + @bottom_left_corner.y)/2]
    p2 = Point[@rightp.x, (@top_right_corner.y + @bottom_right_corner.y)/2]
    s = Segment[p1,p2]
    p3 = Point[(@leftp.x + @rightp.x)/2, 0]
    @center = s.x_projection(p3)
  end
end