require 'spec/spec_helper'

describe XNode do
  it "should be a Node" do
    XNode.superclass.should == Node
  end
  
  it "should be labelled with a end-point of some segment" do
    lambda {XNode.new}.should raise_error(ArgumentError)
    lambda {XNode.new(Point[0,0])}.should_not raise_error(ArgumentError)
  end
  
  it "should know if a point lies to the left or to the right of the vertical line passing to it's point" do
    xnode = XNode.new(Point[0,0])
    xnode.should respond_to :child
    left = Node.new
    right = Node.new
    xnode.left_child, xnode.right_child = left, right
    tests = [[Point[-1,0], left],
             [Point[1,0], right],
             [Point[0,1], right]]
    tests.each do |info|
      xnode.child(info[0]).should == info[1]
    end
  end
  
  it "should know how to paint it self"
  
end