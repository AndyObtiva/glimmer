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
          output_args = @args.to_a.map do |element|
            if element.is_a?(Hash)
              element_output = element.reduce('') do |output, key_value_pair|
                key, value = key_value_pair
                output = "#{output}, " unless output.empty?
                "#{output}#{key}: \"#{value}\""
              end
              "{#{element_output}}"
            else
              element.to_s
            end
          end.join
          output += "(#{output_args})"
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
