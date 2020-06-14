require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/dsl/top_level_expression'

require_relative '../element'

module Glimmer
  module DSL
    module SWT
      class ShellExpression < StaticExpression
        include ParentExpression
        include TopLevelExpression
        
        def interpret(parent, keyword, *args, &block)
          Element.new(parent, "SWT #{keyword}")
        end
      end
    end
  end
end
