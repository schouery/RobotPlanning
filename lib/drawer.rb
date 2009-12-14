require 'lib/segment'
require 'lib/point'

class Drawer
  def initialize(drawing_area)
    @drawing_area = drawing_area
    @gc = Gdk::GC.new(drawing_area)
  end
  
  def draw_segment(segment)
    @drawing_area.draw_line(@gc, segment.start.x, segment.start.y, segment.finish.x, segment.finish.y)
  end
  
  def draw_trapezoid(trapezoid)
    points = [trapezoid.bottom_left_corner.to_a, trapezoid.bottom_right_corner.to_a,
              trapezoid.top_right_corner.to_a, trapezoid.top_left_corner.to_a].uniq
    filled = false
    @drawing_area.draw_polygon(@gc, filled, points)
  end
  
end