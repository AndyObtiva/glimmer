require 'glimmer/dsl/static_expression'

module Glimmer
  module DSL
    module SWT
      # Responsible for providing a readable keyword (command symbol) to capture
      # and return column properties for use in TreeItemsDataBindingCommandHandler
      class ColumnPropertiesExpression < StaticExpression
        include_package 'org.eclipse.swt.widgets'
  
        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'column_properties' and
            block.nil? and
            parent.respond_to?(:swt_widget) and
            parent.swt_widget.is_a?(Table)
        end
  
        def interpret(parent, keyword, *args, &block)
          args
        end
      end
    end
  end
end
