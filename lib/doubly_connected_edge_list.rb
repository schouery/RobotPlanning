class DoublyConnectedEdgeList
  attr_reader :vertices, :edges, :faces
end

class Vertex
  attr_accessor :coordinates, :incidentEdge
end

class Face
  attr_accessor :outerComponent, :innerComponents
end

class HalfEdge
  attr_accessor :origin, :twin, :incidentFace, :next, :prev
end
