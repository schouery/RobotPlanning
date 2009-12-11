require 'spec/spec_helper'

describe Node do
  
  it "should have two childs" do
    Node.new.should respond_to :left_child
    Node.new.should respond_to :right_child
    Node.new.should respond_to :left_child=
    Node.new.should respond_to :right_child=
    Node.new.should respond_to :children
    Node.new.should respond_to :children=
  end
    
  it "should know how to paint it self"
  
end