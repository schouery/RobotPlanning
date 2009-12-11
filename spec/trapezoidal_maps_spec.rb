require 'spec/spec_helper'

describe SearchStructure do

  before(:each) do
    @default = SearchStructure.new_from_bounding_box(
      # segments of bounding box for [[0,0],[1,1]]
      Segment[Point[-1,-1], Point[2,-1]],
      Segment[Point[2,-1], Point[2,2]],
      Segment[Point[2,2], Point[-1,2]],
      Segment[Point[-1,2], Point[-1,-1]])
  end
  
  it "should know it's root" do
    ss = SearchStructure.new
    ss.should respond_to :root
    ss.should respond_to :root=
    node = Node.new
    ss = SearchStructure.new(node)
    ss.root.should == node
  end

  it "should respond to find" do
    SearchStructure.new.should respond_to :find
  end

  it "should know how to search a one-node strutucture" do
    a = TrapezoidNode.new
    ss = SearchStructure.new(a)
    ss.find(Point[0,0]).should == a
  end

  it "should know how to search a two-leaves strutucture" do
    p1 = XNode.new(Point[0,0])
    a, b = TrapezoidNode.new, TrapezoidNode.new
    p1.left_child, p1.right_child = a, b
    ss = SearchStructure.new(p1)
    point1, point2 = Point[1,0], Point[-1,0]
    ss.find(point1).should == a
    ss.find(point2).should == b        
  end  
  
  it "should know how to create a initial search structure from a bounding box" do
    SearchStructure.should respond_to :new_from_bounding_box
    r = @default.root
    r.class.should == TrapezoidNode
    t = r.trapezoid
    t.leftp.should == Point[-1,-1]
    t.rightp.should == Point[2,-1]
    t.top.should == Segment[Point[-1,2],Point[2,2]]
    t.bottom.should == Segment[Point[-1,-1],Point[2,-1]]
  end

  it "should know how to add a segment when there is only one trapezoid" do
    @default.should respond_to :add  
    segment = Segment[Point[0,0], Point[1,1]]
    current = @default.find(segment)
    @default.add(segment)
    intercepting_one_trapezoid(@default.root,nil,segment,current)
  end
  
  it "should know how to insert a segment that intercepts only one trapezoid" do
    @default.add(Segment[Point[0,0],Point[1,1]])
    segment = Segment[Point[0.25, 1.25],Point[0.75, 1.25]]
    current = @default.find(segment, :segment => true)
    @default.add(segment)
    s1 = @default.root.right_child.left_child
    p2 = s1.left_child
    intercepting_one_trapezoid(p2,s1,segment,current)
  end
  
  it "should know how to insert a segment with a commom point on the left with the others segments" do
    @default.add(Segment[Point[0,0],Point[1,1]])
    segment = Segment[Point[0,0], Point[0.5,0.75]]
    current = @default.find(segment, :segment => true)
    @default.add(segment)
    new_location = @default.root.right_child.left_child
    p1 = new_location.left_child
    intercepting_one_trapezoid(p1,new_location,segment,current, :left_collision => @default.root.left_child)    
  end
  
  it "should know how to insert a segment with a commom point on the left with the others segments with slope less than the line" do
    @default.add(Segment[Point[0,0],Point[1,1]])
    segment = Segment[Point[0,0],Point[0.5,0]]
    current = @default.find(segment, :segment => true)
    @default.add(segment)
    new_location = @default.root.right_child.left_child
    p1 = new_location.right_child
    intercepting_one_trapezoid(p1,new_location,segment,current, :left_collision => @default.root.left_child, :with_less_slope => true)    
  end
  
  it "should know how to insert a segment with a commom point on the right with the others segments" do
    @default.add(Segment[Point[0,0], Point[1,1]])
    segment = Segment[Point[0.5,0.75], Point[1,1]]
    current = @default.find(segment, :segment => true)
    @default.add(segment)
    new_location = @default.root.right_child.left_child
    p1 = new_location.left_child
    intercepting_one_trapezoid(p1,new_location,segment,current, :right_collision => @default.root.right_child.right_child)
  end
  
  it "should know how to insert a segment with a commom point on the right with the others segments with slope less than the line" do
    @default.add(Segment[Point[0,0], Point[1,1]])
    segment = Segment[Point[0.5,0.25], Point[1,1]]
    current = @default.find(segment, :segment => true)
    @default.add(segment)
    new_location = @default.root.right_child.left_child
    p1 = new_location.right_child
    intercepting_one_trapezoid(p1,new_location,segment,current, :right_collision => @default.root.right_child.right_child, :with_less_slope => true)    
  end
  
  def intercepting_one_trapezoid(p1, new_location, segment, current, options = {})
    p1.should == XNode.new(segment[0])
    trapezoid = current.trapezoid
    
    a = p1.left_child
    if options[:left_collision]
      a.should == options[:left_collision]
    else
      a.should == TrapezoidNode.new(:leftp => trapezoid.leftp, :rightp => segment.start, :top => trapezoid.top, :bottom => trapezoid.bottom)
    end
    
    q1 = p1.right_child
    q1.should == XNode.new(segment.finish)
    
    s1 = q1.left_child
    s1.should == YNode.new(segment)
  
    b = q1.right_child
    if options[:right_collision]
      b.should == options[:right_collision]
    else
      b.should == TrapezoidNode.new(:leftp => segment.finish, :rightp => trapezoid.rightp, :top => trapezoid.top, :bottom => trapezoid.bottom)    
    end
    
    c = s1.left_child
    c.should == TrapezoidNode.new(:leftp => segment.start, :rightp => segment.finish, :top => trapezoid.top, :bottom => segment)
    
    d = s1.right_child
    d.should == TrapezoidNode.new(:leftp => segment.start, :rightp => segment.finish, :top => segment, :bottom => trapezoid.bottom)
    
    parent_tests = [[a,p1], [b,q1], [c,s1], [d,s1], [s1,q1], [q1,p1], [p1,new_location]]
    parent_tests.each do |child, parent|
      child.parent.should == parent
    end
    
    if(options[:left_collision])
      if(options[:with_less_slope])
        a.neighbours.should == [current.left_neighbours, [d]]
        c.neighbours.should == [[],[b]]
        d.neighbours.should == [[a],[b]]
      else
        a.neighbours.should == [current.left_neighbours, [c]]
        c.neighbours.should == [[a],[b]]
        d.neighbours.should == [[],[b]]                
      end
      b.neighbours.should == [[c,d],current.right_neighbours]
    elsif(options[:right_collision])
      if(options[:with_less_slope])
        b.neighbours.should == [[d],current.right_neighbours]
        c.neighbours.should == [[a],[]]
        d.neighbours.should == [[a],[b]]
      else
        b.neighbours.should == [[c],current.right_neighbours]
        c.neighbours.should == [[a],[b]]
        d.neighbours.should == [[a],[]]
      end
      a.neighbours.should == [current.left_neighbours, [c,d]]
    else
      a.neighbours.should == [current.left_neighbours, [c,d]]
      b.neighbours.should == [[c,d],current.right_neighbours]
      c.neighbours.should == [[a],[b]]
      d.neighbours.should == [[a],[b]]
    end
  end
  
  # it "should work for know problems" do
  #   @ss = SearchStructure.new_from_bounding_box(
  #     Segment[Point[10,10],Point[530,10]],
  #     Segment[Point[530,10],Point[530,530]],
  #     Segment[Point[530,530],Point[530,10]],
  #     Segment[Point[530,10],Point[10,10]])
  #   @ss.add Segment[Point[30,30],Point[200,20]]
  #   @ss.add Segment[Point[230,230],Point[400,200]]
  # end
  
  it "should know how to paint it self"
end