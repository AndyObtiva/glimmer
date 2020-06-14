require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/dsl/top_level_expression'

require_relative '../element'

module Glimmer
  module DSL
    module CSS
      class CssExpression < StaticExpression
        include ParentExpression
        include TopLevelExpression
        
        def interpret(parent, keyword, *args, &block)
          Element.new(parent, "CSS #{keyword}")
        end
      end
    end
  end
end
