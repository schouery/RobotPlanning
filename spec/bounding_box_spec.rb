require 'spec/spec_helper'

describe BoundingBox do
  it "should define a BoundingBox for two points" do
    BoundingBox.should respond_to :box_for
    tests = [[[Point[0,0], Point[1,1]], 1],
             [[Point[0,0], Point[1,1]], 2],
             [[Point[0,0], Point[2,2]], 3]]
    tests.each do |points, dist|
      segments = BoundingBox.box_for(points, dist)
      result = [Point[points[0].x - dist, points[0].y - dist],
                Point[points[1].x + dist, points[0].y - dist],
                Point[points[1].x + dist, points[1].y + dist],
                Point[points[0].x - dist, points[1].y + dist]]
      segments.size.should == 4
      segments.each_with_index do |segment, i|
        segment.should == Segment[result[i],result[(i+1)%4]]
      end
    end
  end
  
  it "should define a BoundigBox for five points" do
    segments = BoundingBox.box_for([Point[2,4],Point[7,3],Point[15,3],Point[5,8],Point[7,7]],1)
    result = [Point[1, 2],
              Point[16,2],
              Point[16,9],
              Point[1,9]]
    segments.size.should == 4
    segments.each_with_index do |segment, i|
      segment.should == Segment[result[i],result[(i+1)%4]]
    end    
  end
  
  it "should define a BoundigBox for zero points (around the origin)" do
    distances = [1,2]
    distances.each do |dist|
      segments = BoundingBox.box_for([], dist)
      segments.size.should == 4
      segments.should == [Segment[Point[-dist,-dist], Point[dist,-dist]],
                          Segment[Point[dist,-dist],Point[dist,dist]],
                          Segment[Point[dist,dist], Point[-dist,dist]],
                          Segment[Point[-dist,dist],Point[-dist,-dist]]]
    end
  end
end