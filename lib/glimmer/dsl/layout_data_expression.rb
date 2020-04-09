require 'glimmer'
require 'glimmer/dsl/static_expression'
require 'glimmer/swt/layout_data_proxy'

# TODO consider turning static keywords like layout_data into methods

module Glimmer
  module DSL
    class LayoutDataExpression < StaticExpression
      def can_interpret?(parent, keyword, *args, &block)
        keyword == 'layout_data' &&
          widget?(parent)
      end

      def interpret(parent, keyword, *args, &block)
        Glimmer.logger.debug "Layout Data args are: #{args.inspect}"
        SWT::LayoutDataProxy.new(parent, args)
      end

      def add_content(parent, &block)
        block.call(parent)
      end
    end
  end
end
