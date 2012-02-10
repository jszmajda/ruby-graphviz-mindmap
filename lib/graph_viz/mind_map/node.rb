class GraphViz
  class MindMap

    class Node
      attr_accessor :name
      attr_accessor :options
      attr_accessor :parent
      attr_accessor :nodes
      attr_accessor :used_identifiers
      attr_accessor :pass_on_options

      def initialize *args
        @options = args.last.is_a?(Hash) ? args.pop : {}
        @name = args.first
        @nodes = []
        @used_identifiers = []
        @pass_on_options = false
        raise ArgumentError.new("You need to name this mind map") unless name
      end

      def inherit!; @pass_on_options = true end
      def no_inherit!; @pass_on_options = false end

      def node(*args, &block)
        @nodes << Node.new(*args).tap do |n| 
          n.parent = self
          if @pass_on_options
            n.options = options.dup.merge(n.options)
            n.pass_on_options = true
          end
        end
        if block_given?
          @nodes.last.instance_eval &block
        end
      end

      # tree walking things

      def at(dot_path)
        path = dot_path.split(/\./)
        if path.any?
          index = path.shift.to_i
          nodes[index].at(path.join('.'))
        else
          self
        end
      end

      def root
        parent ? parent.root : self
      end

      # dot generation things

      def node_def
        opts = dot_options
        o = [dot_identifier]
        if opts.length > 0
          o << ' '
          o << opts
        end
        o.join
      end

      def dot_identifier
        @dot_identifier ||= make_dot_identifier
      end

      def make_dot_identifier
        id = name.downcase.gsub(/[^ a-z]/,'').sub(/ +$/,'').gsub(/ +/,'_')
        if root.used_identifiers.include? id
          id = "#{parent.dot_identifier}_#{id}"
        end
        root.used_identifiers << id
        id
      end

      def dot_options
        o=[]
        unless parent.nil?
          o << "label=\"#{name}\""
        end
        options.each_pair do |k,v|
          o << "#{k}=\"#{v}\""
        end
        if o.any?
          "[#{o.join(' ')}]"
        else
          ''
        end
      end

      # assumes the node you call #to_dot on is the root of the graph and should be treated like a graph
      def to_dot(output=nil, indent=0)
        if indent == 0
          build_dot_from_root
        else
          build_dot_at_index(output,indent)
        end
      end

      def build_dot_from_root
        o = []
        o << "graph #{dot_identifier} {"
        opts = dot_options
        if opts.length > 0
          o << "  graph #{dot_options}"
        end
        nodes.each do |node|
          node.to_dot(o, 1)
        end
        o << "}"
        o.join("\n")
      end

      def build_dot_at_index(o, idx)
        leader = " "*(idx * 2)
        o << "#{leader}#{node_def}"
        if parent && idx > 1
          o << "#{leader}#{parent.dot_identifier} -- #{dot_identifier}"
        end
        if nodes.any?
          o << "#{leader}subgraph sg_#{dot_identifier} {"
          nodes.each do |node|
            node.to_dot(o, idx + 1)
          end
          o << "#{leader}}"
        end
      end
    end
  end
end
