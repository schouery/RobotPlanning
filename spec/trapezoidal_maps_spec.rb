require 'rubygems'
require 'spec'
require 'lib/trapezoidal_maps'

describe SearchStructure do

  it "should know it's root" do
    ss = SearchStructure.new
    ss.should respond_to :root
    ss.should respond_to :root=
    node = mock(Node)
    ss = SearchStructure.new(node)
    ss.root.should == node
  end

  it "should respond to find" do
    SearchStructure.new.should respond_to :find
  end

  it "should know how to search a one-node strutucture" do
    a = mock TrapezoidNode, :class => TrapezoidNode
    ss = SearchStructure.new(a)
    ss.find(mock(Array)).should == a
  end

  it "should know how to search a two-leaves strutucture" do
    p1 = mock XNode, :class => XNode
    a = mock TrapezoidNode, :class => TrapezoidNode
    b = mock TrapezoidNode, :class => TrapezoidNode
    ss = SearchStructure.new(p1)
    point1,point2 = mock(Array), mock(Array)
    p1.should_receive(:child).with(point1).and_return(a)
    p1.should_receive(:child).with(point2).and_return(b)
    ss.find(point1).should == a
    ss.find(point2).should == b        
  end

  it "should know how to search complex structures" do
    # Example from Computational Geometry - de Berg, van Kreveld, Overmars, Schwarzkopf pg 129
    a,b,c,d,e,f,g = (0..7).to_a.collect {mock TrapezoidNode, :class => TrapezoidNode}
    p1,q1,p2,q2 = (0..4).to_a.collect {mock XNode, :class => XNode}
    s1,s2,s2_ = (0..3).to_a.collect {mock YNode, :class => YNode}
    ss = SearchStructure.new(p1)

    points = []
    # 8 possible paths to leaves
    8.times do
      points << mock(Array)
    end

    # point, paths that goes to left, left_child, paths that goes to right, right_child
    expectations = [[p1,  (0..0), a,   (1..7), q1],
                    [q1,  (1..4), s1,  (5..7), q2],
                    [s1,  (1..1), b,   (2..4), p2],
                    [p2,  (2..2), c,   (3..4), s2],
                    [s2,  (3..3), d,   (4..4), f],
                    [q2,  (5..6), s2_, (7..7), g],
                    [s2_, (5..5), e,   (6..6), f]]
    expectations.each do |info|
      info[1].to_a.each do |i|
        info[0].should_receive(:child).with(points[i]).and_return(info[2])
      end
      info[3].to_a.each do |i|
        info[0].should_receive(:child).with(points[i]).and_return(info[4])
      end
    end
        
    [a,b,c,d,f,e,f,g].each_with_index do |trapezoid, i|
      ss.find(points[i]).should == trapezoid
    end
  end
  
end

describe Node do
  
  it "should have two childs" do
    Node.new.should respond_to :left_child
    Node.new.should respond_to :right_child
    Node.new.should respond_to :left_child=
    Node.new.should respond_to :right_child=
  end
  
  it "should know its parent" do
    Node.new.should respond_to :parent
    Node.new.should respond_to :parent=
  end
end

describe XNode do
  it "should be a Node" do
    XNode.superclass.should == Node
  end
  
  it "should be labelled with a end-point of some segment" do
    lambda {XNode.new}.should raise_error(ArgumentError)
    lambda {XNode.new([0,0])}.should_not raise_error(ArgumentError)
  end
  
  it "should know if a point lies to the left or to the right of the vertical line passing to it's point" do
    xnode = XNode.new([0,0])
    xnode.should respond_to :child
    xnode.left_child, xnode.right_child = :left, :right
    tests = [[[-1,0], :left],
             [[1,0], :right],
             [[0,1], nil]]
    tests.each do |info|
      xnode.child(info[0]).should == info[1]
    end
  end
  
end

describe YNode do
  it "should be a Node" do
    YNode.superclass.should == Node
  end
  
  it "should be labelled with a segment" do
    lambda {YNode.new}.should raise_error(ArgumentError)
    lambda {YNode.new(:only_paramenter)}.should raise_error(ArgumentError)
    lambda {YNode.new([0,0],[1,1])}.should_not raise_error(ArgumentError)
  end
  
  it "should know if a point lie above or below the segment stored" do
    YNode.new([0,0],[1,1]).should respond_to :child
    nodes = [YNode.new([0,0],[1,1]), YNode.new([1,1],[0,0])]
    nodes.each do |node|
      node.left_child = :top
      node.right_child = :down
    end
    # [point, left result, right result, child expected]
    tests = [[[0,1], true, false, :top],
            [[1,0], false, true, :down],
            [[0.5,0.5], false, false, nil]]
    tests.each do |info|
      nodes.each do |node|
        node.should_receive(:left).with([0,0],[1,1],info[0]).and_return info[1]
        node.should_receive(:right).with([0,0],[1,1],info[0]).and_return info[2] unless info[1]
        node.child(info[0]).should == info[3]
      end
    end
    
  end
  
  it "should calculate left"
  it "should calculate right"
  
end

describe TrapezoidNode do
  it "should be a Node" do
    TrapezoidNode.superclass.should == Node
  end
end