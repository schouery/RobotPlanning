# Module for the graph
module Graph

  # An Adjacency List implementation of a Graph
  class AdjacencyListGraph
    attr_reader :nodes
    
    #Registers a new vertice
    def add_vertice(node)
      @nodes ||= []
      @nodes << node
      node.graph = self
      node.index = @nodes.size - 1
    end
    
    # Adds an edge from node1 to node2
    def add_edge(node1, node2)
      if node1.graph == self && node2.graph == self
        node1.add_adjacent(node2)
        node2.add_adjacent(node1)
      else
        raise "Error: #{node1.inspect} and #{node2.inspect} shoul belong to #{self.inspect}"
      end
    end

    # Finds a path from start to finish
    def path(start, finish)
      @visited, @parent = [], []
      @path_found = []
      # return nil if dfsR(start, finish).nil?
      pfs(start, finish)
      if @parent[finish.index].nil?
        nil
      else
        construct_path(finish.index)
        @path_found
      end
    end
    
    # Constructs the path, indicating the points that the robot should go through
    def construct_path(i)
      construct_path(@parent[i]) if !@parent[i].nil?
      @path_found << @nodes[i].point
    end
    
    # Deepfirst Search 
    def dfsR(nu, finish)
      return true if nu == finish
      u = nu.index
      @visited[u] = true
      nu.adjacency.each do |nv|
        v = nv.index
        if !@visited[v]
          @parent[v] = u
          r = dfsR(nv, finish)
          return r if r
        end
      end
      nil
    end

    # Djikstra Shortest Path
    def pfs(start, finish)
      pq, @parent = PriorityQueue.new, []
      @nodes.each do |n|
        @parent[n.index] = nil
        pq.add(n.index)
      end
      pq.decrease_key_with_index(start.index, 0)
      while(!pq.empty?)
        min = pq.extract_min
        p, v = min[0], min[1]
        return if p == Float::MAX
        return if v == finish.index
        @nodes[v].adjacency.each do |nw|
          w = nw.index
          if pq.has?(w)
            d = dist(v,w)
            if(p + d < pq.key_of(w))
              pq.decrease_key_with_index(w, p + d)
              @parent[w] = v
            end
          end
        end
      end
    end
    
    # Distance from v to w
    def dist(v,w)
      @nodes[v].point.dist2(@nodes[w].point)
    end
   
    # Draw the edges
    def draw(drawer)
      @nodes.each do |u|
        u.adjacency.each do |v|
          drawer.draw_segment(Segment[u.point, v.point], :graph)
        end
      end
    end
  end
  
  # Represents a Vertice from the Graph
  class Vertice
    
    attr_reader :adjacency, :point
    attr_accessor :graph, :index
    
    def initialize(point = Point[0,0])
      @adjacency = []
      @point = point
    end
    
    # Make node adjacent to this vertice
    def add_adjacent(node)
      @adjacency << node
    end
    
  end
  
  # A Heap implementation of a Priority Queue, based on CLRS.
  class PriorityQueue
    P = 0
    V = 1
    
    def initialize
      @list = []
    end
    
    def empty?
      @list.empty?
    end
    
    # Add a item v if priority v
    def add(v, p = Float::MAX)
      cell = []
      cell[P] = Float::MAX
      cell[V] = v
      @list << cell
      decrease_key(@list.size-1, p)
    end
    
    # Returns the pair element, priority with min priority   
    def min
      @list.fisrt
    end
    
    # Extracts the minimum from the estructure
    def extract_min
      raise "Underflow" if @list.empty?
      min, @list[0] = @list.first, @list.last
      @list.pop
      min_heapify(0)
      min
    end
    
    # Decrease the key on position i    
    def decrease_key(i, key)
      raise "New key is greater than current key" if key > @list[i][P]
      @list[i][P] = key
      p = (i-1)/2
      while(i > 0 && @list[p][P] > @list[i][P])
        @list[p], @list[i] = @list[i], @list[p]
        i = p
        p = (i-1)/2
      end
    end
    
    # Decrease the key of the element w
    def decrease_key_with_index(w, key)
      decrease_key(index(w), key)
    end
    
    # Get the key of element w
    def key_of(w)
      @list[index(w)][P]
    end
    
    # Find the index in the strutucture of the element w
    def index(w)
      @list.index {|a| a[1] == w}
    end
   
    # Return true if the structure has w
    def has?(w)
      true if @list.index {|a| a[1] == w}
    end
    
    def inspect
      @list.inspect
    end
    
    private
    def min_heapify(i)
      l = 2*(i+1) - 1
      r = 2*(i+1)
      if l < @list.size && @list[l][P] < @list[i][P]
        smallest = l
      else
        smallest = i
      end
      if r < @list.size && @list[r][P] < @list[smallest][P]
        smallest = r 
      end
      if smallest != i
        @list[i], @list[smallest] = @list[smallest], @list[i]
        min_heapify(smallest)
      end
    end
    
  end
end