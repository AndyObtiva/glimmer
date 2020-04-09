require 'glimmer'
require 'glimmer/dsl/expression'
require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/tab_item_proxy'

module Glimmer
  module DSL
    class TabItemExpression < Expression
      include_package 'org.eclipse.swt.widgets'

      def can_interpret?(parent, keyword, *args, &block)
        initial_condition = (keyword == 'tab_item') and widget?(parent)
        if initial_condition
          if parent.swt_widget.is_a?(TabFolder)
            return true
          else
            Glimmer.logger.error "tab_item widget may only be used directly under a tab_folder widget!"
          end
        end
        false
      end

      def interpret(parent, keyword, *args, &block)
        SWT::TabItemProxy.new(parent, args)
      end
    end
  end
end
