require 'spec/spec_helper'

describe SearchStructure do
  LEFT, RIGHT = Point[-1,-1], Point[2,-1]
  BOTTOM = Segment[LEFT,RIGHT]
  TOP = Segment[Point[-1,2], Point[2,2]]
  
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
    p1_node = XNode.new(Point[0,0])
    a, b = TrapezoidNode.new, TrapezoidNode.new
    p1_node.left_child, p1_node.right_child = a, b
    ss = SearchStructure.new(p1_node)
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
    p1, q1 = Point[0,0], Point[1,1]
    s1 = Segment[p1,q1]
    @default.add(s1)
    p1_node = @default.root
    a = p1_node.left_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    b = s1_node.left_child
    c = s1_node.right_child
    d = q1_node.right_child
    p1_node.should == XNode.new(p1)
    q1_node.should == XNode.new(q1)
    s1_node.should == YNode.new(s1)
    a.should == TrapezoidNode.new(:leftp => LEFT, :rightp => p1, :top => TOP, :bottom => BOTTOM)
    b.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => TOP, :bottom => s1)
    c.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s1, :bottom => BOTTOM)
    d.should == TrapezoidNode.new(:leftp => q1, :rightp => RIGHT, :top => TOP, :bottom => BOTTOM)
    p1_node.parents.should == []
    a.parents.should       == [p1_node]
    q1_node.parents.should == [p1_node]
    s1_node.parents.should == [q1_node]
    b.parents.should       == [s1_node]
    c.parents.should       == [s1_node]
    d.parents.should       == [q1_node]
    a.left_neighbours.should == []
    a.right_neighbours.should == [b,c]
    b.left_neighbours.should == [a]
    b.right_neighbours.should == [d]
    c.left_neighbours.should == [a]
    c.right_neighbours.should == [d]
    d.left_neighbours.should == [b,c]
    d.right_neighbours.should == []
  end
  
  it "should know how to insert a segment that intercepts only one trapezoid" do
    p1, q1 = Point[0,0], Point[1,1]
    s1 = Segment[p1,q1]
    p2, q2 = Point[0.25,1.25], Point[0.75, 1.25]
    s2 = Segment[p2,q2]
    @default.add(s1)
    @default.add(s2)
    p1_node = @default.root
    a = p1_node.left_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    p2_node = s1_node.left_child
    e = p2_node.left_child
    q2_node = p2_node.right_child
    s2_node = q2_node.left_child
    f = s2_node.left_child
    g = s2_node.right_child
    h = q2_node.right_child
    c = s1_node.right_child
    d = q1_node.right_child
    p1_node.should == XNode.new(p1)
    q1_node.should == XNode.new(q1)
    s1_node.should == YNode.new(s1)
    p2_node.should == XNode.new(p2)
    q2_node.should == XNode.new(q2)
    s2_node.should == YNode.new(s2)
    a.should == TrapezoidNode.new(:leftp => LEFT, :rightp => p1, :top => TOP, :bottom => BOTTOM)
    e.should == TrapezoidNode.new(:leftp => p1, :rightp => p2, :top => TOP, :bottom => s1)
    f.should == TrapezoidNode.new(:leftp => p2, :rightp => q2, :top => TOP, :bottom => s2)
    g.should == TrapezoidNode.new(:leftp => p2, :rightp => q2, :top => s2, :bottom => s1)
    h.should == TrapezoidNode.new(:leftp => q2, :rightp => q1, :top => TOP, :bottom => s1)
    c.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s1, :bottom => BOTTOM)
    d.should == TrapezoidNode.new(:leftp => q1, :rightp => RIGHT, :top => TOP, :bottom => BOTTOM)
    p1_node.parents.should == []
    a.parents.should       == [p1_node]
    q1_node.parents.should == [p1_node]
    s1_node.parents.should == [q1_node]
    p2_node.parents.should == [s1_node]
    e.parents.should       == [p2_node]
    q2_node.parents.should == [p2_node]
    s2_node.parents.should == [q2_node]
    f.parents.should       == [s2_node]
    g.parents.should       == [s2_node]
    h.parents.should       == [q2_node]
    c.parents.should       == [s1_node]
    d.parents.should       == [q1_node]
    a.left_neighbours.should == []
    a.right_neighbours.should == [e,c]
    e.left_neighbours.should == [a]
    e.right_neighbours.should == [f,g]
    f.left_neighbours.should == [e]
    f.right_neighbours.should == [h]
    g.left_neighbours.should == [e]
    g.right_neighbours.should == [h]
    h.left_neighbours.should == [f,g]
    h.right_neighbours.should == [d]
    c.left_neighbours.should == [a]
    c.right_neighbours.should == [d]
    d.left_neighbours.should == [h,c]
    d.right_neighbours.should == []
  end
  
  it "should know how to insert a segment with a commom point on the left with the others segments" do
    p1, q1 = Point[0,0], Point[1,1]
    s1 = Segment[p1,q1]
    p2, q2 = Point[0,0], Point[0.5, 0.75]
    s2 = Segment[p2,q2]
    @default.add(s1)
    @default.add(s2)
    p1_node = @default.root
    a = p1_node.left_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    q2_node = s1_node.left_child
    s2_node = q2_node.left_child
    e = s2_node.left_child
    f = s2_node.right_child
    g = q2_node.right_child
    c = s1_node.right_child
    d = q1_node.right_child
    p1_node.should == XNode.new(p1)
    q1_node.should == XNode.new(q1)
    s1_node.should == YNode.new(s1)
    q2_node.should == XNode.new(q2)
    s2_node.should == YNode.new(s2)
    a.should == TrapezoidNode.new(:leftp => LEFT, :rightp => p1, :top => TOP, :bottom => BOTTOM)
    e.should == TrapezoidNode.new(:leftp => p1, :rightp => q2, :top => TOP, :bottom => s2)
    f.should == TrapezoidNode.new(:leftp => p1, :rightp => q2, :top => s2, :bottom => s1)
    g.should == TrapezoidNode.new(:leftp => q2, :rightp => q1, :top => TOP, :bottom => s1)
    c.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s1, :bottom => BOTTOM)
    d.should == TrapezoidNode.new(:leftp => q1, :rightp => RIGHT, :top => TOP, :bottom => BOTTOM)
    p1_node.parents.should == []
    a.parents.should       == [p1_node]
    q1_node.parents.should == [p1_node]
    s1_node.parents.should == [q1_node]
    c.parents.should       == [s1_node]
    d.parents.should       == [q1_node]
    a.left_neighbours.should == []
    a.right_neighbours.should == [e,c]
    e.left_neighbours.should == [a]
    e.right_neighbours.should == [g]
    f.left_neighbours.should == []
    f.right_neighbours.should == [g]
    g.left_neighbours.should == [e,f]
    g.right_neighbours.should == [d]
    c.left_neighbours.should == [a]
    c.right_neighbours.should == [d]
    d.left_neighbours.should == [g,c]
    d.right_neighbours.should == []
    
  end

  it "should know how to insert a segment with a commom point on the right with the others segments" do
    p1, q1 = Point[0,0], Point[1,1]
    s1 = Segment[p1,q1]
    p2, q2 = Point[0.5,0.75], Point[1,1]
    s2 = Segment[p2,q2]    
    @default.add(s1)
    @default.add(s2)
    p1_node = @default.root
    a = p1_node.left_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    p2_node = s1_node.left_child
    e = p2_node.left_child
    s2_node = p2_node.right_child
    f = s2_node.left_child
    g = s2_node.right_child
    c = s1_node.right_child
    d = q1_node.right_child
    p1_node.should == XNode.new(p1)
    q1_node.should == XNode.new(q1)
    s1_node.should == YNode.new(s1)
    p2_node.should == XNode.new(p2)
    s2_node.should == YNode.new(s2)
    a.should == TrapezoidNode.new(:leftp => LEFT, :rightp => p1, :top => TOP, :bottom => BOTTOM)
    e.should == TrapezoidNode.new(:leftp => p1, :rightp => p2, :top => TOP, :bottom => s1)  
    f.should == TrapezoidNode.new(:leftp => p2, :rightp => q2, :top => TOP, :bottom => s2)
    g.should == TrapezoidNode.new(:leftp => p2, :rightp => q2, :top => s2, :bottom => s1)
    c.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s1, :bottom => BOTTOM)
    d.should == TrapezoidNode.new(:leftp => q1, :rightp => RIGHT, :top => TOP, :bottom => BOTTOM)
    p1_node.parents.should == []
    a.parents.should == [p1_node]
    q1_node.parents.should == [p1_node]
    s1_node.parents.should == [q1_node]
    p2_node.parents.should == [s1_node]
    e.parents.should == [p2_node]
    s2_node.parents.should == [p2_node]
    f.parents.should == [s2_node]
    g.parents.should == [s2_node]
    c.parents.should == [s1_node]
    d.parents.should == [q1_node]
    a.left_neighbours.should == []
    a.right_neighbours.should == [e,c]
    e.left_neighbours.should == [a]
    e.right_neighbours.should == [f,g]
    f.left_neighbours.should == [e]
    f.right_neighbours.should == [d]
    g.left_neighbours.should == [e]
    g.right_neighbours.should == []
    c.left_neighbours.should == [a]
    c.right_neighbours.should == [d]
    d.left_neighbours.should == [f,c]
    d.right_neighbours.should == []
  end
    
  it "should work for crossing segments" do
    p1, q1 = Point[0,0], Point[1,1]
    p2, q2 = Point[-0.25,1.25], Point[1.25, 1.25]
    s1,s2 = Segment[p1,q1], Segment[p2,q2]
    @default.add(s1)
    @default.add(s2)
    p1_node = @default.root
    p2_node = p1_node.left_child
    a = p2_node.left_child
    s2_1_node = p2_node.right_child
    g1 = s2_1_node.left_child
    b = s2_1_node.right_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    s2_2_node = s1_node.left_child
    g2 = s2_2_node.left_child
    c = s2_2_node.right_child
    d = s1_node.right_child
    q2_node = q1_node.right_child
    s2_3_node = q2_node.left_child
    g3 = s2_3_node.left_child
    e = s2_3_node.right_child
    f = q2_node.right_child
    p1_node.should == XNode.new(p1)
    p2_node.should == XNode.new(p2)
    s2_1_node.should == YNode.new(s2)
    s2_2_node.should == YNode.new(s2)
    s2_3_node.should == YNode.new(s2)
    s1_node.should == YNode.new(s1)
    q1_node.should == XNode.new(q1)
    q2_node.should == XNode.new(q2)
    
    a.should == TrapezoidNode.new(:leftp => LEFT, :rightp => p2, :top => TOP, :bottom => BOTTOM)     
    b.should == TrapezoidNode.new(:leftp => p2, :rightp => p1, :top => s2, :bottom => BOTTOM) 
    c.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s2, :bottom => s1)
    d.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s1, :bottom => BOTTOM)
    e.should == TrapezoidNode.new(:leftp => q1, :rightp => q2, :top => s2, :bottom => BOTTOM)
    f.should == TrapezoidNode.new(:leftp => q2, :rightp => RIGHT, :top => TOP, :bottom => BOTTOM)
  
    g1.should == TrapezoidNode.new(:leftp => p2, :rightp => q2, :top => TOP, :bottom => s2)
    g1.object_id.should == g2.object_id
    g1.object_id.should == g3.object_id
    
    p1_node.parents.should == []
    p2_node.parents.should == [p1_node]
    a.parents.should == [p2_node]
    s2_1_node.parents.should == [p2_node]
    b.parents.should == [s2_1_node]
    q1_node.parents.should == [p1_node]
    s1_node.parents.should == [q1_node]
    s2_2_node.parents.should == [s1_node]
    c.parents.should == [s2_2_node]
    d.parents.should == [s1_node]
    q2_node.parents.should == [q1_node]
    s2_3_node.parents.should == [q2_node]
    e.parents.should == [s2_3_node]
    f.parents.should == [q2_node]
    g1.parents.should == [s2_1_node ,s2_2_node, s2_3_node]
   
    a.left_neighbours.should == []
    a.right_neighbours.should == [g1,b]
    b.left_neighbours.should == [a]
    b.right_neighbours.should == [c,d]
    c.left_neighbours.should == [b]
    c.right_neighbours.should == [e]
    d.left_neighbours.should == [b]
    d.right_neighbours.should == [e]
    e.left_neighbours.should == [c,d]
    e.right_neighbours.should == [f]
    f.left_neighbours.should == [g1,e]
    f.right_neighbours.should == []
    g1.left_neighbours.should == [a]
    g1.right_neighbours.should == [f]
    
  end
    
  it "should handle left collision with multiple crossings" do
    p1, q1 = Point[0,0], Point[1,1]
    p2, q2 = Point[-1,-1], Point[0.5, 1]
    s1,s2 = Segment[p1,q1], Segment[p2,q2]
    @default.add(s1)
    @default.add(s2) 
    p1_node = @default.root
    s2_1_node = p1_node.left_child
    b_1 = s2_1_node.left_child
    a = s2_1_node.right_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    q2_node = s1_node.left_child
    s2_2_node = q2_node.left_child
    b_2 = s2_2_node.left_child
    c = s2_2_node.right_child
    d = q2_node.right_child
    e = s1_node.right_child
    f = q1_node.right_child

    p1_node.should == XNode.new(p1)
    s2_1_node.should == YNode.new(s2)
    s2_2_node.should == YNode.new(s2)
    s1_node.should == YNode.new(s1)
    q1_node.should == XNode.new(q1)
    q2_node.should == XNode.new(q2)
    
    a.should == TrapezoidNode.new(:leftp => LEFT, :rightp => p1, :top => s2, :bottom => BOTTOM)
    b_1.should == TrapezoidNode.new(:leftp => LEFT, :rightp => q2, :top => TOP, :bottom => s2) 
    c.should == TrapezoidNode.new(:leftp => p1, :rightp => q2, :top => s2, :bottom => s1)
    d.should == TrapezoidNode.new(:leftp => q2, :rightp => q1, :top => TOP, :bottom => s1)
    e.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s1, :bottom => BOTTOM)
    f.should == TrapezoidNode.new(:leftp => q1, :rightp => RIGHT, :top => TOP, :bottom => BOTTOM)
    b_2.object_id.should == b_1.object_id

    p1_node.parents.should == []
    s2_1_node.parents.should == [p1_node]
    a.parents.should == [s2_1_node]
    q1_node.parents.should == [p1_node]
    s1_node.parents.should == [q1_node]
    q2_node.parents.should == [s1_node]
    s2_2_node.parents.should == [q2_node]
    c.parents.should == [s2_2_node]
    d.parents.should == [q2_node]
    e.parents.should == [s1_node]
    f.parents.should == [q1_node]

    b_1.parents.should == [s2_1_node, s2_2_node]    
       
    a.left_neighbours.should == []
    a.right_neighbours.should == [c,e]

    b_1.left_neighbours.should == []
    b_1.right_neighbours.should == [d]
    
    c.left_neighbours.should == [a]
    c.right_neighbours.should == [d]
    
    d.left_neighbours.should == [b_1,c]
    d.right_neighbours.should == [f]
    
    e.left_neighbours.should == [a]
    e.right_neighbours.should == [f]
    
    f.left_neighbours.should == [d,e]
    f.right_neighbours.should == []
  end
   
  it "should handle right collision with multiple crossings" do 
    p1, q1 = Point[0,0], Point[1,1]
    p2, q2 = Point[0.5, 1], Point[2,2]
    s1,s2 = Segment[p1,q1], Segment[p2,q2]
    @default.add(s1)
    @default.add(s2) 
    p1_node = @default.root
    a = p1_node.left_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    p2_node = s1_node.left_child
    b = p2_node.left_child
    s2_1_node = p2_node.right_child    
    c1 = s2_1_node.left_child
    d = s2_1_node.right_child
    e = s1_node.right_child
    s2_2_node = q1_node.right_child
    c2 = s2_2_node.left_child
    f = s2_2_node.right_child
    
    p1_node.should == XNode.new(p1)
    s2_1_node.should == YNode.new(s2)
    s2_2_node.should == YNode.new(s2)
    s1_node.should == YNode.new(s1)
    q1_node.should == XNode.new(q1)
    p2_node.should == XNode.new(p2)
    
    a.should == TrapezoidNode.new(:leftp => LEFT, :rightp => p1, :top => TOP, :bottom => BOTTOM)
    b.should == TrapezoidNode.new(:leftp => p1, :rightp => p2, :top => TOP, :bottom => s1) 
    c2.should == TrapezoidNode.new(:leftp => p2, :rightp => q2, :top => TOP, :bottom => s2)
    d.should == TrapezoidNode.new(:leftp => p2, :rightp => q1, :top => s2, :bottom => s1)
    e.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s1, :bottom => BOTTOM)
    f.should == TrapezoidNode.new(:leftp => q1, :rightp => q2, :top => s2, :bottom => BOTTOM)
    c2.object_id.should == c1.object_id

    p1_node.parents.should == []
    a.parents.should == [p1_node]
    q1_node.parents.should == [p1_node]
    s1_node.parents.should == [q1_node]
    p2_node.parents.should == [s1_node]
    b.parents.should == [p2_node]
    s2_1_node.parents.should == [p2_node]
    c1.parents.should == [s2_1_node, s2_2_node]
    d.parents.should == [s2_1_node]
    e.parents.should == [s1_node]
    s2_2_node.parents.should == [q1_node]
    f.parents.should == [s2_2_node]

    a.left_neighbours.should == [] 
    a.right_neighbours.should == [b,e]
    b.left_neighbours.should == [a] 
    b.right_neighbours.should == [c1,d]
    c1.left_neighbours.should == [b] 
    c1.right_neighbours.should == []
    d.left_neighbours.should == [b] 
    d.right_neighbours.should == [f]
    e.left_neighbours.should == [a] 
    e.right_neighbours.should == [f]
    f.left_neighbours.should == [d,e] 
    f.right_neighbours.should == []
  end
    
  it "should know how to draw it self" do
    d = mock(Drawer)
    @default.should respond_to :draw
    @default.root.should_receive(:draw).with(d)
    @default.draw(d)
    @default.add(Segment[Point[0,0], Point[1,1]])
    p1 = @default.root
    a = p1.left_child
    q1 = p1.right_child
    si = q1.left_child
    c = si.left_child
    d = si.right_child
    b = q1.right_child
    [a,b,c,d,si].each do |element|
      element.should_receive(:draw).with(d)
    end
    @default.draw(d)
  end
  
  it "should work for know problems 1" do
    os1,os2,os3,os4 = BoundingBox.box_for([Point[20,20],Point[520,20],Point[520,520],Point[20,520]], 10)
    left, right = os1.start, os1.finish
    ss = SearchStructure.new_from_bounding_box(os1,os2,os3,os4)
    p1, q1 = Point[100,100], Point[200,200]
    p2, q2 = Point[200,200], Point[300,100]
    q3, p3 = Point[300,100], Point[100,100]
    s1 = Segment[p1,q1]
    s2 = Segment[p2,q2]
    s3 = Segment[p3,q3]
    ss.add(s1)
    ss.add(s2)
    ss.add(s3)
    p1_node = ss.root
    a = p1_node.left_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    b = s1_node.left_child
    s3_1_node = s1_node.right_child
    h = s3_1_node.left_child
    g1 = s3_1_node.right_child
    q2_node = q1_node.right_child
    s2_node = q2_node.left_child
    d = s2_node.left_child
    s3_2_node = s2_node.right_child
    i = s3_2_node.left_child
    g2 = s3_2_node.right_child
    f = q2_node.right_child

    p1_node.should == XNode.new(p1)
    q1_node.should == XNode.new(q1)
    q2_node.should == XNode.new(q2)
    s1_node.should == YNode.new(s1)
    s2_node.should == YNode.new(s2)
    s3_1_node.should == YNode.new(s3)
    s3_2_node.should == YNode.new(s3)
    
    a.should == TrapezoidNode.new(:leftp => left, :rightp => p1, :top => os3, :bottom => os1)
    b.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => os3, :bottom => s1)
    d.should == TrapezoidNode.new(:leftp => q1, :rightp => q2, :top => os3, :bottom => s2)
    f.should == TrapezoidNode.new(:leftp => q2, :rightp => right, :top => os3, :bottom => os1)
    g1.should == TrapezoidNode.new(:leftp => p1, :rightp => q2, :top => s3, :bottom => os1)
    h.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s1, :bottom => s3)
    i.should == TrapezoidNode.new(:leftp => q1, :rightp => q2, :top => s2, :bottom => s3)
    g2.object_id.should == g1.object_id
    
    a.left_neighbours.should == []
    a.right_neighbours.should == [b,g1]
    b.left_neighbours.should == [a]
    b.right_neighbours.should == [d]
    d.left_neighbours.should == [b]
    d.right_neighbours.should == [f]
    f.left_neighbours.should == [d,g1]
    f.right_neighbours.should == []
    g1.left_neighbours.should == [a]
    g1.right_neighbours.should == [f]
    h.left_neighbours.should == []
    h.right_neighbours.should == [i]
    i.left_neighbours.should == [h]
    i.right_neighbours.should == []    
  end

  it "should work for know problems 2" do
    os1,os2,os3,os4 = BoundingBox.box_for([Point[20,20],Point[520,20],Point[520,520],Point[20,520]], 10)
    left, right = os1.start, os1.finish
    top = os3
    bottom = os1
    ss = SearchStructure.new_from_bounding_box(os1,os2,os3,os4)
    p1, q1 = Point[200, 200], Point[300, 100]
    q2, p2 = Point[300, 100], Point[100, 100]
    p3, q3 = Point[100, 100], Point[200, 200]
    s1 = Segment[p1,q1]
    s2 = Segment[p2,q2]
    s3 = Segment[p3,q3]
    ss.add(s1)    
    p1_node = ss.root
    a = p1_node.left_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    b = s1_node.left_child
    c = s1_node.right_child
    d = q1_node.right_child
    p1_node.should == XNode.new(p1)
    q1_node.should == XNode.new(q1)
    s1_node.should == YNode.new(s1)
    a.should == TrapezoidNode.new(:leftp => left, :rightp => p1, :top => top, :bottom => bottom)
    b.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => top, :bottom => s1)
    c.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => s1, :bottom => bottom)
    d.should == TrapezoidNode.new(:leftp => q1, :rightp => right, :top => top, :bottom => bottom)
    a.left_neighbours.should == []
    a.right_neighbours.should == [b,c]
    b.left_neighbours.should == [a]
    b.right_neighbours.should == [d]
    c.left_neighbours.should == [a]
    c.right_neighbours.should == [d]
    d.left_neighbours.should == [b,c]
    d.right_neighbours.should == []
    ss.add(s2)

    p1_node = ss.root
    p2_node = p1_node.left_child
    e = p2_node.left_child
    s2_1_node = p2_node.right_child
    f = s2_1_node.left_child
    g1 = s2_1_node.right_child
    q1_node = p1_node.right_child
    s1_node = q1_node.left_child
    b = s1_node.left_child
    s2_2_node = s1_node.right_child
    h = s2_2_node.left_child
    g2 = s2_2_node.right_child    
    d = q1_node.right_child
    
    p1_node.should == XNode.new(p1)
    q1_node.should == XNode.new(q1)
    s1_node.should == YNode.new(s1)
    p2_node.should == XNode.new(p2)
    s2_1_node.should == YNode.new(s2)
    s2_2_node.should == YNode.new(s2)
    
    b.should == TrapezoidNode.new(:leftp => p1, :rightp => q1, :top => top, :bottom => s1)
    d.should == TrapezoidNode.new(:leftp => q1, :rightp => right, :top => top, :bottom => bottom)    
  end


end