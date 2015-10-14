module MemoryAnalyzer
  class HeapAnalyzer
    NodeHelper = Struct.new(:node, :heap) do
      def to_s
        str = "#{to_address} - #{node[:type]}(#{to_descriptive_name})"
        str << " - #{node[:location]}" if node.key?(:location)
        str
      end

      def to_descriptive_name
        case node[:type]
        when :CLASS, :MODULE then node[:name]
        when :ROOT           then node[:root]
        when :NODE           then node[:node_type]
        else
          if node[:class]
            heap.by_address[node[:class]][:name]
          else
            node[:type]
          end
        end
      end

      def to_address
        node[:address] || node[:root]
      end
    end
  end
end
