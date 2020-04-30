require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/top_level_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/css/style_sheet'

module Glimmer
  module DSL
    module CSS
      # This static html expression flips the DSL switch on for 
      # XML DSL in Glimmer
      class CssExpression < StaticExpression
        include TopLevelExpression
        include ParentExpression

        def interpret(parent, keyword, *args, &block)
          Glimmer::CSS::StyleSheet.new
        end
      end
    end
  end
end
