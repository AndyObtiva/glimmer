require 'glimmer/dsl/expression'
require 'glimmer/css/rule'

module Glimmer
  module DSL
    module CSS
      module PropertyExpression
        include ParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          parent.is_a?(Glimmer::CSS::Rule) and
            !block_given? and
            !args.empty?
        end

        def interpret(parent, keyword, *args, &block)
          parent.add_property(keyword, *args)
        end
      end
    end
  end
end
