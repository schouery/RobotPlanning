require 'lib/segment'
require 'lib/point'

class Drawer
  
  attr_accessor :segments_color, :graph_color, :trapezoid_base_fill_color, :robot_color, :robot_line_color, :trapezoid_segment_color
  BASE_SPEED = 0.1
  SPEED_FACTOR = 0.1
  
  def initialize(drawing_area, gc)
    # @segments_color = @graph_color = @robot_color = @robot_line_color = 
    # @trapezoid_segment_color = Gdk::Color.new(0x0000,0x0000,0x0000)
    # @trapezoid_base_fill_color = Gdk::Color.new(0xFFFF,0xFFFF,0xFFFF)
    @drawing_area = drawing_area
    @gc = gc
  end
  
  def draw_segment(segment, options = {})
    # @gc.rgb_fg_color = @segments_color
    @drawing_area.draw_line(@gc, segment.start.x, segment.start.y, segment.finish.x, segment.finish.y)
  end
  
  def draw_trapezoid(trapezoid, options = {})
    points = [trapezoid.bottom_left_corner.to_a, trapezoid.bottom_right_corner.to_a,
              trapezoid.top_right_corner.to_a, trapezoid.top_left_corner.to_a].uniq
    # @gc.rgb_fg_color = @trapezoid_base_fill_color
    # @drawing_area.draw_polygon(@gc, true, points)
    # @gc.rgb_fg_color = @trapezoid_segment_color
    @drawing_area.draw_polygon(@gc, false, points)
  end
  
  def clear
    @drawing_area.clear
  end
  
  def draw_circle(x,y, radius = 5, options = {})
    # @gc.rgb_fg_color = @robot_base_color
    @drawing_area.draw_arc(@gc, true, x-radius, y-radius, 2*radius, 2*radius, 0, 360*64)
  end
  
  def slowly_draw_segment(segment, planning, radius = 5, options = {})
    a = segment.start
    b = segment.finish
    if planning.speed == 100 #|| planning.stop
      draw_segment(segment)
    else
      lambda = 0
      dist = Math.sqrt(a.dist2(b))
      while(lambda < 1)
        clear
        yield
        @drawing_area.draw_line(@gc, a.x, a.y, a.x + lambda*b.x - lambda*a.x, a.y + lambda*b.y - lambda*a.y)
        draw_circle(a.x + lambda*b.x - lambda*a.x, a.y + lambda*b.y - lambda*a.y, radius)  
        if planning.speed != 100 && !planning.stop
          sleep(BASE_SPEED)
          lambda += planning.speed/(100*dist*SPEED_FACTOR)
          break if lambda > 1
        else
          return
        end
      end
      clear
      yield
      draw_segment(segment)
      draw_circle(b.x, b.y, radius)
    end
  end  
  
end