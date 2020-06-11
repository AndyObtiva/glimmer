require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    module Opal
      class PropertyExpression < StaticExpression
        include TopLevelExpression

        def can_interpret?(parent, keyword, *args, &block)          
          keyword.to_s == 'text'
        end

        def interpret(parent, keyword, *args, &block)
          parent.text = args.first.to_s
        end
      end
    end
  end
end
