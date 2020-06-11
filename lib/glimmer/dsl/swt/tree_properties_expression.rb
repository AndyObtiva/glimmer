require 'glimmer/dsl/static_expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/tree_items_binding'

module Glimmer
  module DSL
    module SWT
      # Responsible for providing a readable keyword (command symbol) to capture
      # and return tree properties for use in TreeItemsDataBindingCommandHandler
      class TreePropertiesExpression < StaticExpression
        include_package 'org.eclipse.swt.widgets'
  
        def can_interpret?(parent, keyword, *args, &block)
          keyword == "tree_properties" and
            block.nil? and
            parent.respond_to?(:swt_widget) and
            parent.swt_widget.is_a?(Tree)
        end
  
        def interpret(parent, keyword, *args, &block)
          args
        end
      end
    end
  end
end
