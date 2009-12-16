require 'thread'

# Represent the planning for moving the robot, allowing to create the trapezoidal map and
# the underling graph.
class Planning
  attr_accessor :speed, :show_graph, :show_trapezoids, :step_by_step, :stop, :show_line
  BASE_MAP_SPEED = 5.0
  
  def initialize(drawer, statusbar)
    @queue = Queue.new
    @speed = 100.0
    @drawer = drawer
    clear
    @step_by_step = false
    @show_trapezoids = true
    @show_graph = true
    @stop = false
    @segments = []
    @show_line = false
    @statusbar = statusbar
    @context = @statusbar.get_context_id("planning")
  end
  
  # Create the trapezoidal map and the graph
  def start(segments, w, h, &block)
    segments.shuffle!
    d = 0
    @ss = SearchStructure.new_from_bounding_box(
      Segment[Point[d,d], Point[w-d, d]],
      Segment[Point[w-d,d], Point[w-d, h-d]],
      Segment[Point[w-d,h-d], Point[d, h-d]],
      Segment[Point[d,h-d], Point[d, d]])
    @graph = nil
    @segments = segments
    @queue = Queue.new
    Thread.new(block) do
      @stop = !@show_trapezoids
      segments.each do |segment|
        if speed != 100 && !@stop
          new_trapezoids = @ss.update_list(segment)
          new_trapezoids.each do |t|
            @drawer.draw_trapezoid(t, :old => true)
          end
          segment.draw(@drawer)
          wait(BASE_MAP_SPEED/@speed) 
        end
        @ss.add(segment)
        if @speed != 100 && !@stop
          @drawer.clear
          draw_ss
          @ss.new_trapezoids.each do |t|
            @drawer.draw_trapezoid(t.trapezoid, :new => true)
          end
          wait(5.0/@speed)
        end
      end
      draw_ss if @stop
      @graph = @ss.create_graph
      wait(BASE_MAP_SPEED/@speed) if speed != 100 && !@stop
      draw_graph if @stop
      draw
      block.call
    end
  end
  
  def wait(time)
    if @step_by_step
      @queue.deq
    else
      sleep(5.0/@speed)
    end
  end
    
  def clear
    @graph, @ss, @segments = nil, nil, []
  end
  
  def next_step
    @queue.enq(:step)
  end
  
  # Draw the trapezoidal map 
  def draw_ss
    @ss.draw(@drawer) if @ss && @show_trapezoids
  end
  
  # Draw the graph
  def draw_graph
    @graph.draw(@drawer) if @graph && @show_graph
  end
  
  # Activate and Deactivate the step by step mode
  def toggle_step_by_step
    @step_by_step = !@step_by_step
  end
  
  # Find a path from start to finish if it exists
  def locate(start, finish, &block)
    @stop = false
    @queue = Queue.new
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
              already_drew.each {|ad| @drawer.draw_segment(ad, :robot)} if @show_line
            end
            already_drew << s
            old = v
          end
          draw
          already_drew.each {|ad| @drawer.draw_segment(ad, :robot)} if @show_line
          @drawer.draw_circle(finish.x, finish.y, 5, :robot)
        else
          @statusbar.push(@context, "Não existe caminho de #{start.inspect} até #{finish.inspect}")
          draw
        end
      end
      block.call
    end
  end

  # Draws all the structures
  def draw
    @drawer.clear
    draw_ss
    draw_graph
    @segments.each do |s|
      s.draw(@drawer)   
    end
  end

end