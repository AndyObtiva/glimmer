require 'glimmer/dsl/expression'
require 'glimmer/dsl/parent_expression'

require_relative '../element'

module Glimmer
  module DSL
    module SWT
      class SwtDynamicExpression < Expression
        include ParentExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          return true unless ['html', 'body', 'input', 'color', 'font_size', 'text'].include?(keyword)
        end
        
        def interpret(parent, keyword, *args, &block)
          name = "SWT Dynamic #{keyword}"
          if keyword.include?('_with_around_stack')
            name += "(#{Context.around_stack.join(',')})"
          end
          Element.new(parent, name, args)
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
