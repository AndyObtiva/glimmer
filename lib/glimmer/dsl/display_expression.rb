require 'glimmer/dsl/expression'
require 'glimmer/swt/display_proxy'

module Glimmer
  module DSL
    class DisplayExpression < Expression
      def can_interpret?(parent, keyword, *args, &block)
        keyword == 'display'
      end

      def interpret(parent, keyword, *args, &block)
        SWT::DisplayProxy.instance(*args)
      end
    end
  end
end
