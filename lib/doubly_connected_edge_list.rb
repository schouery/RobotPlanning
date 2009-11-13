class DoublyConnectedEdgeList
  attr_reader :vertices, :edges, :faces
  def initialize
    @vertices, @edges, @faces = [], [], []
  end
end

class Vertex
  attr_accessor :coordinates, :incidentEdge

  def initialize(*coordinates)
    if !coordinates || coordinates.empty?
      @coordinates = [0,0]
    else
      @coordinates = coordinates
    end
  end

end

class Face
  attr_accessor :outerComponent, :innerComponents
end

class HalfEdge
  attr_accessor :origin, :twin, :incidentFace, :next, :prev
end