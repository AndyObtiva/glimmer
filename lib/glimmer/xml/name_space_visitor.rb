require File.dirname(__FILE__) + "/node_visitor"

module Glimmer
  module XML
    class NameSpaceVisitor < NodeVisitor

      def initialize(name_space_name)
        @name_space_name = name_space_name
      end

      def process_before_children(node)
        return if node.is_a?(String)
        node.name_space = Node.new(nil, @name_space_name, nil) if node and !node.name_space
      end

      def process_after_children(node)
        #NOOP
      end
    end
  end
end
