require 'glimmer/dsl/static_expression'
require 'glimmer/xml/node'

module Glimmer
  module DSL
    module XML
      class TextExpression < StaticExpression
        def can_interpret?(parent, keyword, *args, &block)
          (parent == nil or parent.is_a?(Glimmer::XML::Node)) and
          (keyword.to_s == "text") and
          (args.size == 1) and
          !block
        end

        def interpret(parent, keyword, *args, &block)
          parent.children << args[0].to_s if parent
          args[0].to_s
        end
      end
    end
  end
end
