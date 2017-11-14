require 'json'
require 'ruby-progressbar'

module MemoryAnalyzer
  class HeapAnalyzer
    class Parser
      attr_reader :file
      attr_accessor :show_progress

      def initialize(file, show_progress = true)
        @file = file
        @show_progress = show_progress
      end

      def parse
        if show_progress
          parse_file_with_progress
        else
          parse_file
        end
      end

      private

      def parse_file_with_progress
        progress = ProgressBar.create(
          :title         => "Parsing",
          :total         => io_class.open(file) {|f| f.each_line.count },
          :format        => "%t: |%B| %e",
          :throttle_rate => 0.1
        )
        parse_file { progress.increment }
          .tap { progress.finish }
      end

      def parse_file
        io_class.open(file) do |f|
          f.each_line.collect do |line|
            yield if block_given? # For progress reporting
            enhance_node(clean_node(parse_line(line)))
          end
        end
      end

      def parse_line(line)
        JSON.parse(line, :symbolize_names => true)
      end

      # Add elements to the node that will be used later by the analyzer
      def enhance_node(node)
        enhance_node_with_location!(node)
        node
      end

      def enhance_node_with_location!(node)
        location = node.values_at(:file, :line).compact.join(":")
        node[:location] = string_pool_intern(location) unless location.empty?
      end

      # Modify the existing elements of the node to save memory
      def clean_node(node)
        clean_strings_via_symbolizing!(node)
        clean_strings_via_pooling!(node)
        clean_references!(node)
        node
      end

      # Symbolize common simple strings to save memory
      def clean_strings_via_symbolizing!(node)
        %i(type node_type).each do |key|
          node[key] = node[key].to_sym if node.key?(key)
        end
      end

      # Use a StringPool to share common immutable strings to save memory
      def clean_strings_via_pooling!(node)
        %i(address file class method value).each do |key|
          node[key] = string_pool_intern(node[key]) if node.key?(key)
        end
      end

      # Remove duplicate references and add empty Arrays for nodes without
      #   references to prevent having to check later during usage
      def clean_references!(node)
        refs = Array(node[:references])
        refs.uniq!
        refs.map! { |r| string_pool_intern(r) }
        node[:references] = refs
      end

      def string_pool
        @string_pool ||= StringPool.new
      end

      def string_pool_intern(string)
        string_pool.add(string)[string]
      end

      def io_class
        if has_gzip_magic_number? || File.extname(file) == ".gz"
          require 'zlib'
          Zlib::GzipReader
        else
          File
        end
      end

      GZ_MAGIC_NUMBER = "\x1F\x8B".force_encoding("ASCII-8BIT").freeze
      def has_gzip_magic_number?
        File.binread(file, 2) == GZ_MAGIC_NUMBER
      end
    end
  end
end
