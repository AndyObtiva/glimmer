require 'glimmer/dsl/expression'
require 'glimmer/css/rule_set'

module Glimmer
  module DSL
    module CSS
      class PropertyExpression < Expression
        include ParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          parent.is_a?(Glimmer::CSS::RuleSet) and
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
