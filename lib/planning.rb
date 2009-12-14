class Planning

  def initialize(segments)
    segments.shuffle!
    p segments
    s1,s2,s3,s4 = BoundingBox.box_for([Point[20,20],Point[520,20],Point[520,520],Point[20,520]], 10)
    @ss = SearchStructure.new_from_bounding_box(s1,s2,s3,s4)
    segments.each do |segment|
      @ss.add(segment)
    end
    @graph = @ss.create_graph
  end
  
  def draw_ss(drawer)
    @ss.draw(drawer)
  end
  
  def draw_graph(drawer)
    @graph.draw(drawer)
  end
  
  def locate(start, finish, drawer)
    sn = @ss.find(start)
    fn = @ss.find(finish)
    if sn == fn
      drawer.draw_segment Segment[start, finish]
    else
      path = @graph.path(sn.vertice, fn.vertice)
      old = start
      path.each do |v|
        drawer.draw_segment Segment[old, v.point]
        old = v.point
      end
      drawer.draw_segment Segment[fn.vertice.point, finish]
    end
  end

end