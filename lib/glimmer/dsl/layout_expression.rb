require 'glimmer'
require 'glimmer/dsl/expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/layout_proxy'

module Glimmer
  module DSL
    class LayoutExpression < Expression
      include ParentExpression

      include_package 'org.eclipse.swt.widgets'

      def can_interpret?(parent, keyword, *args, &block)
        keyword.to_s.end_with?('_layout') and
          widget?(parent) and
          parent.swt_widget.is_a?(Composite) and
          SWT::LayoutProxy.layout_exists?(keyword.to_s)
      end

      def interpret(parent, keyword, *args, &block)
        SWT::LayoutProxy.new(keyword, parent, args)
      end
    end
  end
end
