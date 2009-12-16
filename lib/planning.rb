class Planning
  attr_accessor :speed, :show_graph, :show_trapezoids, :step_by_step, :stop
  BASE_MAP_SPEED = 5.0
  
  def initialize(drawer)
    @speed = 100.0
    @drawer = drawer
    clear
    @step_by_step = false
    @show_trapezoids = true
    @show_graph = true
    @stop = false
    @segments = []
  end
    
  def start(segments, w, h, &block)
    segments.shuffle!
    d = 0
    @ss = SearchStructure.new_from_bounding_box(
      Segment[Point[d,d], Point[w-d, d]],
      Segment[Point[w-d,d], Point[w-d, h-d]],
      Segment[Point[w-d,h-d], Point[d, h-d]],
      Segment[Point[d,h-d], Point[d, d]])
    @graph = nil
    Thread.new(block) do
      @stop = !@show_trapezoids
      segments.each do |segment|
        @ss.add(segment)
        if @speed != 100 && !@stop
          @drawer.clear
          draw_ss
          sleep(5.0/@speed)
        end
      end
      draw_ss if @stop
      @graph = @ss.create_graph
      sleep(BASE_MAP_SPEED/@speed) if speed != 100 && !@stop
      draw_graph if @stop
      draw
      block.call
    end
    @segments = segments
  end
    
  def clear
    @graph, @ss, @segments = nil, nil, []
  end
  
  def draw_ss
    @ss.draw(@drawer) if @ss && @show_trapezoids
  end
  
  def draw_graph
    @graph.draw(@drawer) if @graph && @show_graph
  end
  
  def toggle_step_by_step
    @step_by_step = !@step_by_step
  end
  
  def locate(start, finish, &block)
    @stop = false
    Thread.new(block) do
      sn = @ss.find(start)
      fn = @ss.find(finish)
      if sn == fn
        @drawer.slowly_draw_segment(Segment[start, finish], self) do
          draw
        end
      else
        path = @graph.path(sn.vertice, fn.vertice)
        if !path.nil?
          already_drew = []
          old = start
          path << finish
          path.each do |v|
            s = Segment[old, v]
            @drawer.slowly_draw_segment(s, self) do
              draw
              already_drew.each {|ad| @drawer.draw_segment(ad)}
            end
            already_drew << s
            old = v
          end
          draw
          already_drew.each {|ad| @drawer.draw_segment(ad)}
          @drawer.draw_circle(finish.x, finish.y, 5)
        else
          draw
        end
      end
      block.call
    end
  end

  def draw
    @drawer.clear
    draw_ss
    draw_graph
    @segments.each do |s|
      s.draw(@drawer)   
    end
  end

end