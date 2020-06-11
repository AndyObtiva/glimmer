require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/opal/label'

module Glimmer
  module DSL
    module Opal
      class LabelExpression < StaticExpression
        include ParentExpression

        def interpret(parent, keyword, *args, &block)
          Glimmer::Opal::Label.new(parent, args)
        end
      end
    end
  end
end
