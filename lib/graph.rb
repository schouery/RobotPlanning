module Graph

  class AdjacencyListGraph
    attr_reader :nodes
    
    def add_vertice(node)
      @nodes ||= []
      @nodes << node
      node.graph = self
      node.index = @nodes.size - 1
    end
    
    def add_edge(node1, node2)
      if node1.graph == self && node2.graph == self
        node1.add_adjacent(node2)
        node2.add_adjacent(node1)
      else
        raise "Error: #{node1.inspect} and #{node2.inspect} shoul belong to #{self.inspect}"
      end
    end

    def path(start, finish)
      @visited, @parent = [], []
      @path_found = []
      # return nil if dfsR(start, finish).nil?
      return nil if pfs(start, finish).nil?
      construct_path(finish.index)
      @path_found
    end
    
    def construct_path(i)
      construct_path(@parent[i]) if !@parent[i].nil?
      @path_found << @nodes[i]
    end
    
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

    def pfs(start, finish)
      pq, @parent = PriorityQueue.new, []
      @nodes.each do |n|
        @parent[n.index] = nil
        pq.add(n.index)
      end
      pq.increase_priority(start.index, 0)
      while(!pq.empty?)
        return nil if pq.first_priority.nil?
        return true if pq.first == finish.index
        v = pq.del_min
        @nodes[v].adjacency.each do |nw|
          w = nw.index
          if(pq.priority[w].nil? || pq.priority[v] + dist(v,w) < pq.priority[w])
            pq.increase_priority(w, pq.priority[v] + dist(v,w))
            @parent[w] = v
          end
        end
      end
      nil
    end
    
    def dist(v,w)
      @nodes[v].point.dist2(@nodes[w].point)
    end
   
    def draw(drawer)
      @nodes.each do |u|
        u.adjacency.each do |v|
          drawer.draw_segment(Segment[u.point, v.point])
        end
      end
    end
  end
  
  class Vertice
    
    attr_reader :adjacency, :point
    attr_accessor :graph, :index
    
    def initialize(point = Point[0,0])
      @adjacency = []
      @point = point
    end
    
    def add_adjacent(node)
      @adjacency << node
    end
    
  end
  
  class PriorityQueue
    attr_reader :list, :priority
    def initialize
      @list = []
      @priority = []
    end
    
    def empty?
      @list.empty?
    end
    
    def add(item, p = nil)
      @list << item
      @priority[item] = p
    end
    
    def fix_up(k)
      a, b = @list[k], @list[k/2]
      while(k >= 1 && !@priority[a].nil? && (@priority[b].nil? || @priority[b] > @priority[a]))
        @list[k/2], @list[k] = @list[k], @list[k/2]
        k = k/2
        a, b = @list[k], @list[k/2]
      end      
    end
   
    def increase_priority(k, v)
      @priority[k] = v
      i = @list.index(k)
      fix_up(i)
    end
    
    def del_min
      @list.shift
    end
   
    def first
      @list[0]
    end
    
    def first_priority
      @priority[@list[0]]
    end
  end
end