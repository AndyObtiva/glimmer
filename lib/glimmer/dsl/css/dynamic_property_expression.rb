require 'glimmer/dsl/expression'
require 'glimmer/dsl/css/property_expression'

module Glimmer
  module DSL
    module CSS
      class DynamicPropertyExpression < Expression
        include PropertyExpression
      end
    end
  end
end
