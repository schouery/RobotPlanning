#Generate a bounding box
module BoundingBox
  # Receive a list of points and a dist of this point that should be respected and creates a box (list of segments)
  # who is a bounding box for this points
  def self.box_for(points, dist)
    points = [Point[0,0]] if points.nil? || points.empty?    
    minx = points.reduce(points[0].x) {|min,point| min = min > point.x ? point.x : min}
    maxx = points.reduce(points[0].x) {|max,point| max = max < point.x ? point.x : max}
    miny = points.reduce(points[0].y) {|min,point| min = min > point.y ? point.y : min}
    maxy = points.reduce(points[0].y) {|max,point| max = max < point.y ? point.y : max}
    limits = [Point[minx-dist,miny-dist],Point[maxx+dist,miny-dist], Point[maxx+dist,maxy+dist], Point[minx-dist,maxy+dist]]
    res = []
    for i in 0..3 do
      res << Segment[limits[i], limits[(i+1)%4]]
    end
    res
  end
end