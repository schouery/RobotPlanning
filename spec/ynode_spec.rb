require 'spec/spec_helper'

describe YNode do
  it "should be a Node" do
    YNode.superclass.should == Node
  end
  
  it "should be labelled with a segment" do
    segment = Segment[Point[0,0],Point[1,1]]
    lambda {YNode.new}.should raise_error(ArgumentError)
    lambda {YNode.new(segment)}.should_not raise_error(ArgumentError)
  end
  
  it "should know if a point lie above or below the segment stored" do
    p1 = Point[0,0]
    p2 = Point[1,1]
    s1 = Segment[p1,p2]
    s2 = Segment[p2,p1]
    YNode.new(s1).should respond_to :child
    nodes = [YNode.new(s1), YNode.new(s2)]
    top = Node.new
    bottom = Node.new
    nodes.each do |node|
      node.left_child = top
      node.right_child = bottom
    end
    # [point, left result, right result, child expected]
    tests = [[Point[0,1], true, false, top],
             [Point[1,0], false, true, bottom],
             [Point[0.5,0.5], false, false, nil]]
    tests.each do |info|
      nodes.each do |node|
        node.child(info[0]).should == info[3]
      end
    end  
  end
  
  it "should know if a segment lie above or below the segment stored" do
    s = Segment[Point[0,0],Point[1,1]]
    node = YNode.new(s)
    segment1 = Segment[Point[0,0],Point[0.5,0.75]]
    segment2 = Segment[Point[0,0],Point[0.5,-0.75]]
    
    top = Node.new
    bottom = Node.new
    node.left_child = top
    node.right_child = bottom
    
    node.child(segment1, :segment => true).should == top
    node.child(segment2, :segment => true).should == bottom
  end
  
  it "should know how to draw it self" do
    s = mock(Segment)
    d = mock(Drawer)
    s.should_receive(:new_left_to_right).and_return(s)
    node = YNode.new(s)
    node.should respond_to :draw
    s.should_receive(:draw).with(d)
    node.draw(d)
  end
  
end