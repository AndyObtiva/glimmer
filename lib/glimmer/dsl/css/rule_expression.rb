require 'glimmer/dsl/expression'
require 'glimmer/css/style_sheet'
require 'glimmer/css/rule'

module Glimmer
  module DSL
    module CSS
      class RuleExpression < Expression
        include ParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          parent.is_a?(Glimmer::CSS::StyleSheet) and
            block_given? and
            args.empty?
        end

        def interpret(parent, keyword, *args, &block)
          Glimmer::CSS::Rule.new(keyword.to_s.downcase).tap do |rule|
            parent.rules << rule
          end
        end
      end
    end
  end
end
