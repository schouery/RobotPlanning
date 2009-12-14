class Planning

  def initialize(segments, w, h)
    @segments = segments.shuffle
    # p @segments
    d = 3
    @ss = SearchStructure.new_from_bounding_box(
      Segment[Point[d,d], Point[w-d, d]],
      Segment[Point[w-d,d], Point[w-d, h-d]],
      Segment[Point[w-d,h-d], Point[d, h-d]],
      Segment[Point[d,h-d], Point[d, d]])
    @segments.each do |segment|
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