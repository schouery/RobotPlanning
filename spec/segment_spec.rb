require 'spec/spec_helper'

describe Segment do

  before(:each) do
    @start = Point[0,0]
    @finish = Point[1,1]
    @default = Segment.new(@start, @finish)
  end
  
  it "should consist of two points" do
    @default.should respond_to :start
    @default.should respond_to :finish
    @default.start.should == @start
    @default.finish.should == @finish
  end
  
  it "should create a segment in a elegant way" do
    Segment.should respond_to :[]
    Segment[@start,@finish].should == @default
  end
  
  it "should test correctly for ==" do
    @default.should == Segment.new(@start, @finish)
  end
  
  it "should know how to create a left-to-right oriented segment" do
    segment = Segment.new(@finish, @start)
    segment.should respond_to :new_left_to_right
    segment.new_left_to_right.should == @default
    @default.new_left_to_right.should == @default
  end

  it "should calculate left" do
    @default.should respond_to :left
    @default.left(Point[0,1]).should == true
    @default.left(Point[1,0]).should == false
  end
  
  it "should calculate right" do
    @default.should respond_to :right
    @default.right(Point[0,1]).should == false
    @default.right(Point[1,0]).should == true
  end
  
  it "should respond to []" do
    @default.should respond_to :[]
  end

  it "should calculate the x-projection" do
    @default.should respond_to :x_projection
    @default.x_projection(Point[0,0]).should be_instance_of(Point)
    @default.x_projection(Point[0,0]).should == Point[0,0]
    @default.x_projection(Point[0.5,1]).should == Point[0.5,0.5]
    segment1 = Segment[Point[0,0], Point[0,1]]
    segment2 = Segment[Point[0,1], Point[0,0]]
    segment1.x_projection(Point[1,1]).should be_nil
    segment2.x_projection(Point[1,1]).should be_nil
    segment1.x_projection(Point[0,0.5]).should == Point[0,0.5]
    segment2.x_projection(Point[0,0.5]).should == Point[0,0.5]
    segment1.x_projection(Point[0,1.1]).should == Point[0,1]
    segment2.x_projection(Point[0,1.1]).should == Point[0,1]
  end

  it "should know how to draw itself" do
    @default.should respond_to :draw
    d = mock(Drawer)
    d.should_receive(:draw_segment).with(@default)
    @default.draw(d)
  end

end
