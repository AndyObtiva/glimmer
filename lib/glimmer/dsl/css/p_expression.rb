require 'glimmer/dsl/static_expression'
require 'glimmer/css/style_sheet'
require 'glimmer/css/rule_set'

# TODO avoid using p as it clashes with HTML p
module Glimmer
  module DSL
    module CSS
      class PExpression < StaticExpression
        include ParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'p' and
            parent.is_a?(Glimmer::CSS::RuleSet) and
            !block_given? and
            !args.empty? and
            args.size > 1
        end

        def interpret(parent, keyword, *args, &block)
          parent.add_property(args[0], args[1])
        end
      end
    end
  end
end
