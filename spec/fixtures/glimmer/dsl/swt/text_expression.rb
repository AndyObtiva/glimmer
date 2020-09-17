require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'

require_relative '../element'

module Glimmer
  module DSL
    module SWT
      class TextExpression < StaticExpression
        include ParentExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          return true unless args&.first&.is_a?(Numeric)
        end
        
        def interpret(parent, keyword, *args, &block)        
          parent.args = args
        end
      end
    end
  end
end
