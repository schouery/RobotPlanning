require 'spec/spec_helper'

describe TrapezoidNode do
  it "should be a Node" do
    TrapezoidNode.superclass.should == Node
  end
  
  it "should receive info for creating a trapezoid on initialization" do
    t = TrapezoidNode.new(:leftp => Point[1,3],
                          :rightp => Point[5,2],
                          :top => Segment[Point[-1,10],Point[7,8]], 
                          :bottom => Segment[Point[-3,-5], Point[6,1]])
    t.should respond_to :trapezoid
    t.trapezoid.should == Trapezoid.new(:leftp => Point[1,3],
                                        :rightp => Point[5,2],
                                        :top => Segment[Point[-1,10],Point[7,8]], 
                                        :bottom => Segment[Point[-3,-5], Point[6,1]])
  end
  
  it "should know it's left neighbours" do
    t = TrapezoidNode.new
    t.should respond_to :left_neighbours
    t.should respond_to :left_neighbours=
    t.left_neighbours.should == []
  end
  
  it "should know it's right neighbours" do
    t = TrapezoidNode.new
    t.should respond_to :right_neighbours
    t.should respond_to :right_neighbours=
    t.right_neighbours.should == []
  end
  
  it "should know it's neigbours (both of them)" do
    t = TrapezoidNode.new
    t.should respond_to :neighbours
    t.should respond_to :neighbours=
    t.neighbours.should == [[],[]]
  end
  
  it "should know how to draw it self" do
    t = TrapezoidNode.new
    d = mock(Drawer)
    t.trapezoid.should_receive(:draw).with(d)
    t.draw(d)
  end
  
end