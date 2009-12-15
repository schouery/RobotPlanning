class Planning
  attr_accessor :speed
  attr_reader :playing
  
  def initialize(drawer, toolbar_generate_map)
    @speed = 100.0
    @drawer = drawer
    clear
    @toolbar_generate_map = toolbar_generate_map
    @playing = false
    @step_by_step = false
  end
  
  def start(segments, w, h)
    @playing = true
    segments.shuffle!
    # p segments
    d = 0
    @ss = SearchStructure.new_from_bounding_box(
      Segment[Point[d,d], Point[w-d, d]],
      Segment[Point[w-d,d], Point[w-d, h-d]],
      Segment[Point[w-d,h-d], Point[d, h-d]],
      Segment[Point[d,h-d], Point[d, d]])
    @graph = nil
    Thread.new do
      segments.each do |segment|
        @ss.add(segment)
        if @speed != 100
          @drawer.clear
          draw_ss
          sleep(5.0/@speed)
        end
      end
      draw_ss
      @graph = @ss.create_graph
      sleep(5.0/@speed) if speed != 100
      draw_graph
      @toolbar_generate_map.active = false
      @playing = false
    end
  end
  
  def clear
    @graph, @ss = nil, nil
  end
  
  def draw_ss
    @ss.draw(@drawer) if @ss
  end
  
  def draw_graph
    @graph.draw(@drawer) if @graph
  end
  
  def change_step_by_step
    @step_by_step = !@step_by_step
  end
  
  def locate(start, finish)
    sn = @ss.find(start)
    fn = @ss.find(finish)
    if sn == fn
      @drawer.draw_segment Segment[start, finish]
    else
      path = @graph.path(sn.vertice, fn.vertice)
      return if path.nil?
      old = start
      path.each do |v|
        @drawer.draw_segment Segment[old, v.point]
        old = v.point
      end
      @drawer.draw_segment Segment[fn.vertice.point, finish]
    end
  end

end