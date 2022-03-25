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
        
        case_insensitive true
        
        def interpret(parent, keyword, *args, &block)
          Element.new(parent, "SWT #{keyword}")
        end
        
        def around(parent, keyword, args, block, &interpret_and_add_content)
          Context.around_stack.push keyword
          yield
          Context.around_stack.pop
        end
      end
    end
  end
end
