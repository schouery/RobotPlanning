require 'rubygems'
require 'spec'
require 'lib/doubly_connected_edge_list'

describe DoublyConnectedEdgeList do
  it "should have vertices" do
    d = DoublyConnectedEdgeList.new
    d.should respond_to :vertices
    d.vertices.class.should == Array
  end
  
  it "should have edges" do
    d = DoublyConnectedEdgeList.new
    d.should respond_to :edges
    d.edges.class.should == Array
  end

  it "should have faces" do
    d = DoublyConnectedEdgeList.new
    d.should respond_to :faces
    d.faces.class.should == Array
  end
end

describe Vertex do
  it "should have coordinates" do
    Vertex.new.should respond_to :coordinates
  end

  it "should initialize with coordinates" do
    Vertex.new.coordinates.should == [0,0]
    Vertex.new(1,2).coordinates.should == [1,2]
  end
  
  it "should have incidentEdge" do
    Vertex.new.should respond_to :incidentEdge
  end
end

describe Face do
  it "should have outerComponent" do
    Face.new.should respond_to :outerComponent
  end
  #lista de arestas
  it "should have InnerComponents" do
    Face.new.should respond_to :innerComponents
  end
end

describe HalfEdge do
  it "should have origin" do
    HalfEdge.new.should respond_to :origin
  end
  it "should have twin" do
    HalfEdge.new.should respond_to :twin
  end
  it "should have incidentFace" do
    HalfEdge.new.should respond_to :incidentFace
  end
  it "should have next" do
    HalfEdge.new.should respond_to :next
  end
  it "should have prev" do
    HalfEdge.new.should respond_to :prev
  end
end
