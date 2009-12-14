require 'lib/segment'
require 'lib/point'

class ConvexHull
  #Graham
  def self.generate(points)
    points = points.dup
    min = 0
    points.each_with_index do |p, i|
       min = i if points[min].y > p.y || (points[min].y == p.y && points[min].x > p.x)
    end
    points[min], points[0] = points[0], points[min]
    ini = points.shift
    points.sort! do |x,y| 
      if Segment[ini, y].right(x) || (Segment[ini, y].collinear(x) && x.dist2(ini) > y.dist2(ini))
        -1
      else
        1
      end
    end
    p points
    h = [ini]
    h << points.shift
    points.shift while(Segment[h[0], h[1]].collinear(points[0]))
    h << points.shift    
    p h
    points.each do |p|
      while(!Segment[h[h.size-2],h[h.size-1]].left(p))
        h.pop
      end
      h << p #if !Segment[h[h.size-2],h[h.size-1]].collinear(p)
    end
    h.pop if Segment[h[h.size-2],h[0]].collinear(h[h.size-1])
    
    old = h.last
    r = []
    h.each do |p|
      r << Segment[old,p]
      old = p
    end
    r
  end
end