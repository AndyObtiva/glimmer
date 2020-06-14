require 'glimmer/dsl/expression'

require_relative '../element'

module Glimmer
  module DSL
    module CSS
      class PropertyDynamicExpression < Expression        
        def can_interpret?(parent, keyword, *args, &block)
          return true
        end
        
        def interpret(parent, keyword, *args, &block)
          parent.args = args
        end
      end
    end
  end
end
