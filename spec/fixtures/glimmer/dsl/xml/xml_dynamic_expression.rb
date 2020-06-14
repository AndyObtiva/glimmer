require 'glimmer/dsl/expression'
require 'glimmer/dsl/parent_expression'

require_relative '../element'

module Glimmer
  module DSL
    module XML
      class XmlDynamicExpression < Expression
        include ParentExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          return true unless keyword == 'content'
        end
        
        def interpret(parent, keyword, *args, &block)
          Element.new(parent, "XML Dynamic #{keyword}", args)
        end
      end
    end
  end
end
