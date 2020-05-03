require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/css/property_expression'

module Glimmer
  module DSL
    module CSS
      # Static keyword 'pv' version of CSS DSL dynamic property expression
      class PVExpression < StaticExpression
        include PropertyExpression

        def interpret(parent, keyword, *args, &block)
          parent.add_property(args[0], args[1])
        end
      end
    end
  end
end
