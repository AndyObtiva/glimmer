require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/table_items_binding'

module Glimmer
  module DSL
    #Depends on BindCommandHandler and TableColumnPropertiesDataBindingCommandHandler
    class TableItemsDataBindingExpression < Expression
      include_package 'org.eclipse.swt.widgets'

      def can_interpret?(parent, keyword, *args, &block)
        keyword == "items" &&
          block.nil? &&
          widget?(parent) &&
          parent.widget.is_a?(Table) &&
          args.size == 2 &&
          args[0].is_a?(DataBinding::ModelBinding) &&
          args[0].evaluate_property.is_a?(Array) &&
          args[1].is_a?(Array)
      end

      def interpret(parent, keyword, *args, &block)
        model_binding = args[0]
        column_properties = args[1]
        DataBinding::TableItemsBinding.new(parent, model_binding, column_properties)
      end
    end
  end
end
