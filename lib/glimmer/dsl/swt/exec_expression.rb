require 'glimmer/swt/display_proxy'

module Glimmer
  module DSL
    # Mixin for common code in async_exec and sync_exec expressions
    # Uses name in subclass to auto-derive exec_operation
    module ExecExpression
      def exec_operation
        @exec_operation ||= self.class.name.split(/::/).last.sub(/Expression$/, '').underscore
      end

      def can_interpret?(parent, keyword, *args, &block)
        keyword == exec_operation and
          block_given? and
          args.empty?
      end

      def interpret(parent, keyword, *args, &block)
        SWT::DisplayProxy.instance.send(exec_operation, &block)
      end
    end
  end
end
