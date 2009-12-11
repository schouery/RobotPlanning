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

end
