require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/table_items_binding'

module Glimmer
  module DSL
    module SWT
      #Depends on BindCommandHandler and TableColumnPropertiesDataBindingCommandHandler
      class TableItemsDataBindingExpression < Expression
        include_package 'org.eclipse.swt.widgets'
  
        def can_interpret?(parent, keyword, *args, &block)
          keyword == "items" and
            block.nil? and
            parent.respond_to?(:swt_widget) and
            parent.swt_widget.is_a?(Table) and
            args.size == 2 and
            args[0].is_a?(DataBinding::ModelBinding) and
            args[0].evaluate_property.is_a?(Array) and
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
end
