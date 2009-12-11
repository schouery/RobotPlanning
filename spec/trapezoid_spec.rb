require 'spec/spec_helper'

describe Trapezoid do
  
  it "should know it's left point" do
    t = Trapezoid.new
    t.should respond_to :leftp
    t.should respond_to :leftp=
  end
  
  it "should know it's right point" do
    t = Trapezoid.new
    t.should respond_to :rightp
    t.should respond_to :rightp=
  end
  
  it "should know it's top segment" do
    t = Trapezoid.new
    t.should respond_to :top
    t.should respond_to :top=
  end
  
  it "should know it's lower segment" do
    t = Trapezoid.new
    t.should respond_to :bottom
    t.should respond_to :bottom=
  end
  
  it "should suport a hash for config" do
    t = Trapezoid.new(:leftp => Point[1,3],
                      :rightp => Point[5,2],
                      :top => Segment[Point[-1,10],Point[7,8]],
                      :bottom => Segment[Point[-3,-5], Point[6,1]])
    t.leftp.should == Point[1,3]
    t.rightp.should == Point[5,2]
    t.top.should == Segment[Point[-1,10], Point[7,8]]
    t.bottom.should == Segment[Point[-3,-5], Point[6,1]]
    
    t = Trapezoid.new(:leftp => Point[1,3],
                      :rightp => Point[5,2],
                      :top => Segment[Point[7,8],Point[-1,10]],
                      :bottom => Segment[Point[6,1], Point[-3,-5]])
    t.leftp.should == Point[1,3]
    t.rightp.should == Point[5,2]
    t.top.should == Segment[Point[-1,10], Point[7,8]]
    t.bottom.should == Segment[Point[-3,-5], Point[6,1]]
  end

  it "should respond correctly to equals" do
    t1 = Trapezoid.new(:leftp => Point[1,3],
                      :rightp => Point[5,2],
                      :top => Segment[Point[-1,10],Point[7,8]],
                      :bottom => Segment[Point[-3,-5], Point[6,1]])
    t2 = Trapezoid.new(:leftp => Point[1,3],
                      :rightp => Point[5,2],
                      :top => Segment[Point[-1,10],Point[7,8]],
                      :bottom => Segment[Point[-3,-5], Point[6,1]])    
    t1.should == t2
  end
  
  it "should know how to paint it self"  
end