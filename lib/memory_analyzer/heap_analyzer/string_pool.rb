require 'set'

module MemoryAnalyzer
  class HeapAnalyzer
    class StringPool < Set
      def add(o)
        unless include?(o)
          o = o.dup.freeze unless o.frozen?
          @hash[o] = o
        end
        self
      end

      alias :<< :add

      def [](o)
        @hash[o]
      end
    end
  end
end
