module Glimmer
  module DSL
    class Element
      attr_accessor :args
    
      def initialize(parent, name, args = nil)
        @parent = parent
        @name = name
        @parent.children << self if @parent&.children
        @args = args
      end
      
      def children
        @children ||= []
      end
      
      def to_s
        output = @name.to_s
        if @args && !@args.to_a.empty?
          output += "(#{@args.to_a.map(&:to_s).join})"
        end
        if !children.empty?
          output += " { "
          output += children.map(&:to_s).join
          output += " }"
        end
        output
      end
    end
  end
end
