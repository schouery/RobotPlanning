require 'spec/spec_helper'

describe Drawer do

  before(:each) do
    @gdk_window = mock(Gdk::Window)
    Gdk::GC.should_receive(:new).and_return nil
    @default = Drawer.new(@gdk_window)
  end

  it "should know how to draw a segment" do    
    @default.should respond_to :draw_segment
    @gdk_window.should_receive(:draw_line).with(any_args)
    @default.draw_segment(Segment[Point[0,0], Point[1,1]])
  end
  
  it "is wrong" #o ultimo
  
  it "shoul know how to draw a trapezoid" do
    @default.should respond_to :draw_trapezoid
    @gdk_window.should_receive(:draw_polygon).with(any_args)    
    @default.draw_trapezoid(Trapezoid.new)
  end
  
end