require 'glimmer/dsl/expression'
require 'glimmer/css/style_sheet'
require 'glimmer/css/rule_set'

module Glimmer
  module DSL
    module CSS
      class RuleSetExpression < Expression
        include ParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          parent.is_a?(Glimmer::CSS::StyleSheet) and
            block_given? and
            args.empty?
        end

        def interpret(parent, keyword, *args, &block)
          Glimmer::CSS::RuleSet.new(keyword.to_s.downcase).tap do |rule_set|
            parent.rule_sets << rule_set
          end
        end
      end
    end
  end
end
