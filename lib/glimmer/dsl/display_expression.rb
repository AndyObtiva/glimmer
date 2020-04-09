require 'glimmer/dsl/static_expression'
require 'glimmer/swt/display_proxy'

module Glimmer
  module DSL
    class DisplayExpression < StaticExpression
      def interpret(parent, keyword, *args, &block)
        SWT::DisplayProxy.instance(*args)
      end
    end
  end
end
