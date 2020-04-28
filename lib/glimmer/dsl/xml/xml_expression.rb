require 'glimmer/dsl/xml/node_parent_expression'
require 'glimmer/dsl/expression'
require 'glimmer/xml/node'

module Glimmer
  module DSL
    module XML
      class XmlExpression < Expression
        include NodeParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          (parent == nil or parent.is_a?(Glimmer::XML::Node)) and
          (args.size == 0 or ((args.size == 1) and ((args[0].is_a?(Hash)) or (args[0].is_a?(Hash)))))
        end

        def interpret(parent, keyword, *args, &block)
          attributes = Hash.new
          attributes = args[0] if (args.size == 1)
          Glimmer::XML::Node.new(parent, keyword.to_s, attributes, &block)
        end
      end
    end
  end
end
