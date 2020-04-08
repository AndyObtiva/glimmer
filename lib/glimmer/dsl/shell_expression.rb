require 'glimmer/dsl/expression'
require 'glimmer/swt/shell_proxy'

module Glimmer
  module SWT
    class ShellExpression < Expression
      def can_interpret?(parent, keyword, *args, &block)
        keyword == 'shell'
      end

      def interpret(parent, keyword, *args, &block)
        SWT::ShellProxy.send(:new, *args)
      end

      def add_content(parent, &block)
        block.call(parent)
      end
    end
  end
end
