require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/dsl/top_level_expression'
require 'glimmer/swt/display_proxy'

module Glimmer
  module DSL
    module SWT
      class DisplayExpression < StaticExpression
        include TopLevelExpression
        include ParentExpression

        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::DisplayProxy.instance(*args)
        end
      end
    end
  end
end
