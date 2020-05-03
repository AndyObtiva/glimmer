require 'glimmer'
require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/tab_item_proxy'

module Glimmer
  module DSL
    module SWT
      class TabItemExpression < StaticExpression
        include ParentExpression
  
        include_package 'org.eclipse.swt.widgets'
  
        def can_interpret?(parent, keyword, *args, &block)
          initial_condition = (keyword == 'tab_item') and widget?(parent)
          if initial_condition
            if parent.swt_widget.is_a?(TabFolder)
              return true
            else
              Glimmer::Config.logger&.error "tab_item widget may only be used directly under a tab_folder widget!"
            end
          end
          false
        end
  
        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::TabItemProxy.new(parent, args)
        end
      end
    end
  end
end
