require 'spec/spec_helper'

describe Point do

  it "should have X-axis" do
    p = Point.new(0,0)
    p.should respond_to :x
    p.should respond_to :x=
    p.x = 1
    p.x.should == 1
  end

  it "should have Y-axis" do
    p = Point.new(0,0)
    p.should respond_to :y
    p.should respond_to :y=
    p.y = 1
    p.y.should == 1
  end

  it "should start of the coordinates" do
    p = Point.new(1,2)
    p.x.should == 1
    p.y.should == 2
  end
  
  it "should create a point in a elegant way" do
    Point.should respond_to :[]
    Point[1,2].should == Point.new(1,2)
  end

  it "should work for ==" do
    p1 = Point.new(1,2)
    p2 = Point.new(1,2)
    p1.should == p2
  end
  
end