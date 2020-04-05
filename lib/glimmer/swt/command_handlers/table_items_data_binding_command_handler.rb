require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_widget"
require File.dirname(__FILE__) + "/../custom_widget"
require File.dirname(__FILE__) + "/../table_items_binding"

module Glimmer
  module SWT
    module CommandHandlers
      #Depends on BindCommandHandler and TableColumnPropertiesDataBindingCommandHandler
      class TableItemsDataBindingCommandHandler
        include CommandHandler

        include_package 'org.eclipse.swt.widgets'

        def can_handle?(parent, command_symbol, *args, &block)
          command_symbol.to_s == "items" &&
            block == nil &&
            (parent.is_a?(GWidget) || parent.is_a?(CustomWidget)) &&
            parent.widget.is_a?(Table) &&
            args.size == 2 &&
            args[0].is_a?(ModelBinding) &&
            args[0].evaluate_property.is_a?(Array) &&
            args[1].is_a?(Array)
        end

        def do_handle(parent, command_symbol, *args, &block)
          model_binding = args[0]
          column_properties = args[1]
          TableItemsBinding.new(parent, model_binding, column_properties)
        end
      end
    end
  end
end
