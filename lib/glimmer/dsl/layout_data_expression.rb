require 'glimmer/dsl/expression'
require 'glimmer/swt/layout_data_proxy'

module Glimmer
  module DSL
    class LayoutDataExpression < Expression
      def can_interpret?(parent, keyword, *args, &block)
        keyword == 'layout_data' &&
          widget?(parent)
      end

      def interpret(parent, keyword, *args, &block)
        Glimmer.logger.debug "Layout Data args are: #{args.inspect}"
        SWT::LayoutDataProxy.new(parent.widget, args)
      end

      def add_content(parent, &block)
        block.call(parent)
      end
    end
  end
end
