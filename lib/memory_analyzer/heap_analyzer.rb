require 'json'
require 'ruby-progressbar'
require 'set'
require 'active_support/core_ext/hash/keys'

# ["address", "type", "class", "frozen", "embedded", "bytesize", "value",
#  "encoding", "file", "line", "method", "generation", "memsize", "flags"]

module MemoryAnalyzer
  class HeapAnalyzer
    attr_reader :file, :nodes

    def initialize(file)
      @file = file
    end

    def index_by_address
      index_all
      @index_by_address
    end

    def index_by_location
      index_all
      @index_by_location
    end

    def index_by_referencing_address
      index_all
      @index_by_referencing_address
    end

    def roots
      index_all
      @roots
    end

    def find_by_location(regex)
      full_key = index_by_location.keys.grep(regex).first
      index_by_location[full_key].first
    end

    def walk_references(address, indent = 0, seen = Set.new)
      print("  " * indent)

      node = index_by_address[address]
      if node.nil?
        puts "#{address} - **MISSING**"
        return
      end

      line = node_to_s(node)

      if seen.include?(address)
        puts "#{line} **SEEN**"
      else
        puts line
        seen << address
        Array(node[:references]).uniq.each { |ref| walk_references(ref, indent + 1, seen) }
      end

      nil
    end

    def walk_parents(address, indent = 0, seen = Set.new)
      print("  " * indent)

      node = index_by_address[address]
      if node.nil?
        puts "#{address} - **MISSING**"
        return
      end

      parents = index_by_referencing_address[address]

      line = node_to_s(node)

      if seen.include?(address)
        puts "#{line} **SEEN**"
      else
        puts line
        seen << address
        parents.each { |n| walk_parents(node_to_address(n), indent + 1, seen) }
      end

      nil
    end

    def parse_with_progress
      progress = ProgressBar.create(
        :title         => "Parsing",
        :total         => `wc -l #{file}`.split.first.to_i,
        :format        => "%t: |%B| %e",
        :throttle_rate => 0.1
      )
      parse do
        progress.increment
      end
      progress.finish
    end

    def parse
      @nodes =
        File.open(file) do |f|
          f.each_line.collect do |l|
            yield if block_given? # For progress reporting
            clean_node(JSON.parse(l))
          end
        end

      nil
    end

    def inspect
      to_s.dup.chop << " @file=#{file.inspect}>"
    end

    private

    def clean_node(node)
      node.tap do |n|
        n.deep_symbolize_keys!
      end
    end

    def index_all
      return if @indexed

      @index_by_address = {}
      @index_by_location = Hash.new { |h, k| h[k] = Set.new }
      @index_by_referencing_address = Hash.new { |h, k| h[k] = Set.new }
      @roots = Set.new

      nodes.each do |node|
        @index_by_address[node_to_address(node)] = node
        @index_by_location[node_to_location(node)] << node

        Array(node[:references]).each do |ref|
          @index_by_referencing_address[ref] << node
        end

        @roots << node if node[:address].nil?
      end

      @indexed = true
    end

    def node_to_s(node)
      str = "#{node_to_address(node)} - #{node[:type]}(#{node_to_descriptive_name(node)})"
      location = node_to_location(node)
      str << " - #{location}" if location
      str
    end

    def node_to_location(node)
      location = node.values_at("file", "line").compact
      location.empty? ? nil : location.join(":")
    end

    def node_to_descriptive_name(node)
      case node[:type]
      when "CLASS", "MODULE" then node[:name]
      when "ROOT"            then node[:root]
      when "NODE"            then node[:node_type]
      else
        if node[:class]
          index_by_address[node[:class]][:name]
        else
          node[:type]
        end
      end
    end

    def node_to_address(node)
      node[:address] || node[:root]
    end
  end
end
