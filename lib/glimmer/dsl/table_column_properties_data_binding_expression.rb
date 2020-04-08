require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    # Responsible for providing a readable keyword (command symbol) to capture
    # and return column properties for use in TreeItemsDataBindingCommandHandler
    class TableColumnPropertiesDataBindingExpression < Expression
      include_package 'org.eclipse.swt.widgets'

      def can_interpret?(parent, keyword, *args, &block)
        keyword == 'column_properties' &&
          block == nil &&
          widget?(parent) &&
          parent.widget.is_a?(Table)
      end

      def interpret(parent, keyword, *args, &block)
        args
      end
    end
  end
end
