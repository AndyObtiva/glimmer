require 'glimmer/dsl/expression'
require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/tab_item_proxy'

module Glimmer
  module DSL
    class TabItemExpression < Expression
      include_package 'org.eclipse.swt.widgets' #TODO move to DSL

      def can_interpret?(parent, keyword, *args, &block)
        initial_condition = (keyword == 'tab_item') && widget?(parent)
        if initial_condition
          if parent.widget.is_a?(TabFolder)
            return true
          else
            Glimmer.logger.error "tab_item widget may only be used directly under a tab_folder widget!"
          end
        end
        false
      end

      def interpret(parent, keyword, *args, &block)
        tab_item = SWT::WidgetProxy.new(keyword.to_s, parent.widget, args)
        SWT::TabItemProxy.new(tab_item, parent.widget, args)
      end
    end
  end
end
