require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'

require_relative '../element'

module Glimmer
  module DSL
    module XML
      class ContentExpression < StaticExpression
        include ParentExpression
        
        def interpret(parent, keyword, *args, &block)        
          parent.args = args
        end
      end
    end
  end
end
