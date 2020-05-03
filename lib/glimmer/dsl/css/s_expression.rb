require 'glimmer/dsl/static_expression'
require 'glimmer/css/style_sheet'
require 'glimmer/css/rule'

module Glimmer
  module DSL
    module CSS
      class SExpression < StaticExpression
        include ParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          keyword == 's' and
            parent.is_a?(Glimmer::CSS::StyleSheet) and
            block_given? and
            !args.empty?
        end

        def interpret(parent, keyword, *args, &block)
          Glimmer::CSS::Rule.new(args.first.to_s).tap do |rule|
            parent.rules << rule
          end
        end
      end
    end
  end
end
