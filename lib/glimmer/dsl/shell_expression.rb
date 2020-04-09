require 'glimmer/dsl/static_expression'
require 'glimmer/swt/shell_proxy'

module Glimmer
  module DSL
    class ShellExpression < StaticExpression
      def interpret(parent, keyword, *args, &block)
        SWT::ShellProxy.send(:new, *args)
      end

      def add_content(parent, &block)
        pd parent
        pd Glimmer::DSL::Engine.current_parent
        block.call(parent)
      end
    end
  end
end
