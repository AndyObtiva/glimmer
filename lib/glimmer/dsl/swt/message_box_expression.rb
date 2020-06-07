require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/dsl/top_level_expression'
require 'glimmer/swt/shell_proxy'
require 'glimmer/swt/message_box_proxy'
require 'glimmer/swt/swt_proxy'

module Glimmer
  module DSL
    module SWT
      class MessageBoxExpression < StaticExpression
        include TopLevelExpression
        include ParentExpression

        include_package 'org.eclipse.swt.widgets'

        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'message_box'
        end

        def interpret(parent, keyword, *args, &block)
          potential_parent = args.first
          parent = args.shift if potential_parent.is_a?(Shell) || (potential_parent.respond_to?(:swt_widget) && potential_parent.swt_widget.is_a?(Shell))
          Glimmer::SWT::MessageBoxProxy.new(parent, Glimmer::SWT::SWTProxy[args])
        end
      end
    end
  end
end
