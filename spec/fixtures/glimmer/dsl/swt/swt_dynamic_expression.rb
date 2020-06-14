require 'glimmer/dsl/expression'
require 'glimmer/dsl/parent_expression'

require_relative '../element'

module Glimmer
  module DSL
    module SWT
      class SwtDynamicExpression < Expression
        include ParentExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          return true unless ['html', 'body', 'input', 'color', 'font_size'].include?(keyword)
        end
        
        def interpret(parent, keyword, *args, &block)
          Element.new(parent, "SWT Dynamic #{keyword}", args)
        end
      end
    end
  end
end
