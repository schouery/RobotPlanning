require 'spec/spec_helper'

describe Drawer do

  before(:each) do
    @gdk_window = mock(Gdk::Window)
    @gc = mock(Gdk::GC)
    @default = Drawer.new(@gdk_window, @gc)
  end

  it "should know how to draw a segment" do    
    @default.should respond_to :draw_segment
    @gdk_window.should_receive(:draw_line).with(any_args)
    @gc.should_receive(:rgb_fg_color=).twice.with(any_args)
    @default.draw_segment(Segment[Point[0,0], Point[1,1]])
  end
  
  it "shoul know how to draw a trapezoid" do
    @default.should respond_to :draw_trapezoid
    @gdk_window.should_receive(:draw_polygon).twice.with(any_args)    
    @gc.should_receive(:rgb_fg_color=).at_least(:once).with(any_args)
    @gdk_window.should_receive(:draw_line).twice.with(any_args)
    @default.draw_trapezoid(Trapezoid.new)
  end
  
end
