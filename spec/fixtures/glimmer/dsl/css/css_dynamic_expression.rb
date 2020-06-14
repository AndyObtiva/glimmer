require 'glimmer/dsl/expression'
require 'glimmer/dsl/parent_expression'

require_relative '../element'

module Glimmer
  module DSL
    module CSS
      class CssDynamicExpression < Expression
        include ParentExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          return true if args.to_a.empty?
        end
        
        def interpret(parent, keyword, *args, &block)
          Element.new(parent, "CSS Dynamic #{keyword}", args)
        end
      end
    end
  end
end
