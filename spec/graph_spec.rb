require 'spec_helper'

describe Graph::AdjacencyListGraph do
  it "should support small graphs" do
    g = Graph::AdjacencyListGraph.new
    node1 = Graph::Vertice.new
    g.should respond_to :add_vertice
    g.add_vertice(node1)
    g.should respond_to :nodes
    g.nodes.should == [node1]
    
    node2 = Graph::Vertice.new
    g.add_vertice(node2)
    g.nodes.should == [node1, node2]
    g.should respond_to :add_edge
    g.add_edge(node1, node2)
    
    node1.should respond_to :adjacency
    node1.adjacency.should == [node2]
    node2.adjacency.should == [node1]
  end
  
  it "should use shortest path for path"
end

describe Graph::Vertice do  
  it "should store it's point" do
    g = Graph::Vertice.new(Point[0,0])
    g.point.should == Point[0,0]
  end
end