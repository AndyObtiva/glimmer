require 'glimmer/dsl/xml/node_parent_expression'
require 'glimmer/dsl/expression'
require 'glimmer/xml/node'

module Glimmer
  module DSL
    module XML
      class XmlExpression < Expression
        include NodeParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          parent.is_a?(Glimmer::XML::Node)
        end

        def interpret(parent, keyword, *args, &block)
          Glimmer::XML::Node.new(parent, keyword.to_s, args, &block)
        end
      end
    end
  end
end
