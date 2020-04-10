require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/shell_proxy'

module Glimmer
  module DSL
    class ShellExpression < StaticExpression
      include ParentExpression

      def interpret(parent, keyword, *args, &block)
        SWT::ShellProxy.send(:new, *args)
      end
    end
  end
end
