require 'glimmer'
require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/layout_data_proxy'

# TODO consider turning static keywords like layout_data into methods

module Glimmer
  module DSL
    class LayoutDataExpression < StaticExpression
      include ParentExpression

      def can_interpret?(parent, keyword, *args, &block)
        keyword == 'layout_data' and
          widget?(parent)
      end

      def interpret(parent, keyword, *args, &block)
        Glimmer.logger&.debug "Layout Data args are: #{args.inspect}"
        SWT::LayoutDataProxy.new(parent, args)
      end
    end
  end
end
