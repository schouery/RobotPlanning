require 'lib/segment'
require 'lib/point'

# Resposable for all the drawings in the project
class Drawer
  attr_accessor :segments_color, :graph_color, :trapezoid_base_fill_color, :robot_color, :robot_line_color, :trapezoid_segment_color,
  :old_trapezoid_color, :new_trapezoid_color
  BASE_SPEED = 0.1
  SPEED_FACTOR = 0.1
  
  def initialize(drawing_area, gc)
    @black = Gdk::Color.new(0x0000, 0x0000, 0x0000)
    @white = Gdk::Color.new(0xFFFF, 0xFFFF, 0xFFFF)
    @segments_color = @graph_color = @robot_color = @robot_line_color = 
    @trapezoid_segment_color = @black
    @trapezoid_base_fill_color = @white
    @new_trapezoid_color = Gdk::Color.new(0x9999, 0x9999, 0x8888)
    @old_trapezoid_color = Gdk::Color.new(0xBBBB, 0xBBBB, 0x9999)
    @drawing_area = drawing_area
    @gc = gc
  end

  # Draw a segment, the possible modes are:
  # * :graph: Paint using graph color
  # * :robot: Paint using robot color
  # * default: Paint using segments color
  def draw_segment(segment, mode = nil)
    case mode
      when :graph
        @gc.rgb_fg_color = @graph_color
      when :robot
        @gc.rgb_fg_color = @robot_line_color
      else
        @gc.rgb_fg_color = @segments_color
    end
    @drawing_area.draw_line(@gc, segment.start.x, segment.start.y, segment.finish.x, segment.finish.y)
    @gc.rgb_fg_color = @black
  end
  
  # Draw a trapezoid, using the the fill color and segment color
  # After that, draws the original segments so make it better to see
  def draw_trapezoid(trapezoid, options = {})
    points = [trapezoid.bottom_left_corner.to_a, trapezoid.bottom_right_corner.to_a,
              trapezoid.top_right_corner.to_a, trapezoid.top_left_corner.to_a].uniq
    if options[:new]
      @gc.rgb_fg_color = @new_trapezoid_color
    elsif options[:old]
      @gc.rgb_fg_color = @old_trapezoid_color
    else
      @gc.rgb_fg_color = @trapezoid_base_fill_color
    end
    
    @drawing_area.draw_polygon(@gc, true, points)
    @gc.rgb_fg_color = @trapezoid_segment_color
    @drawing_area.draw_polygon(@gc, false, points)
  
    @gc.rgb_fg_color = @segments_color
    @drawing_area.draw_line(@gc, trapezoid.bottom_left_corner.x, trapezoid.bottom_left_corner.y,
     trapezoid.bottom_right_corner.x, trapezoid.bottom_right_corner.y)
     @drawing_area.draw_line(@gc, trapezoid.top_left_corner.x, trapezoid.top_left_corner.y,
      trapezoid.top_right_corner.x, trapezoid.top_right_corner.y)
      
    @gc.rgb_fg_color = @black  
  end
  
  # Clear the drawing area
  def clear
    @drawing_area.clear
  end
  
  # Draws a circle, the possible modes are:
  # * :robot : Use the robot color
  # * default: Use black
  def draw_circle(x,y, radius = 5, mode = nil)
    if mode == :robot
      @gc.rgb_fg_color = @robot_color
    else
      @gc.rgb_fg_color = @black
    end
    @drawing_area.draw_arc(@gc, true, x-radius, y-radius, 2*radius, 2*radius, 0, 360*64)
    @gc.rgb_fg_color = @black
  end
  
  # Slowly draw a segment, that is, draw a series of segments with a pause, that converges to
  # the actual segment
  def slowly_draw_segment(segment, planning, radius = 5)
    a = segment.start
    b = segment.finish
    if planning.speed == 100 || planning.stop
      draw_segment(segment, :robot) if planning.show_line
    else
      lambda = 0
      dist = Math.sqrt(a.dist2(b))
      while(lambda < 1)
        clear
        yield
        @gc.rgb_fg_color = @robot_line_color
        @drawing_area.draw_line(@gc, a.x, a.y, a.x + lambda*b.x - lambda*a.x, a.y + lambda*b.y - lambda*a.y) if planning.show_line
        draw_circle(a.x + lambda*b.x - lambda*a.x, a.y + lambda*b.y - lambda*a.y, radius, :robot)  
        if planning.speed != 100 && !planning.stop
          sleep(BASE_SPEED)
          lambda += planning.speed/(100*dist*SPEED_FACTOR)
          break if lambda > 1
        else
          @gc.rgb_fg_color = @black
          return
        end
      end
      clear
      yield
      draw_segment(segment, :robot) if planning.show_line
      draw_circle(b.x, b.y, radius, :robot)
    end
    @gc.rgb_fg_color = @black
  end  
  
end