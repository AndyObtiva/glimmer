require 'glimmer/dsl/expression'
require 'glimmer/swt/layout_proxy'

module Glimmer
  module DSL
    class LayoutExpression < Expression
      include_package 'org.eclipse.swt.widgets'

      def can_interpret?(parent, keyword, *args, &block)
        keyword.to_s.end_with?('_layout') &&
          widget?(parent) &&
          parent.widget.is_a?(Composite) &&
          SWT::LayoutProxy.layout_exists?(keyword.to_s)
      end

      def interpret(parent, keyword, *args, &block)
        Glimmer.logger.debug "Layout #{keyword} args are: #{args.inspect}"
        SWT::LayoutProxy.new(keyword.to_s, parent.widget, args)
      end

      def add_content(parent, &block)
        block.call(parent)
      end
    end
  end
end
