require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'

require_relative '../element'

module Glimmer
  module DSL
    module SWT
      class SpinnerExpression < StaticExpression
        include ParentExpression
        
        # this always returns false as it is only testing that dynamic expressions
        # get used if this static expresion cannot interpret
        def can_interpret?(parent, keyword, *args, &block)
          false
        end
      end
    end
  end
end
