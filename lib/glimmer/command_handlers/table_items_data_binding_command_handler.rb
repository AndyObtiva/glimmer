require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/g_widget"
require File.dirname(__FILE__) + "/models/table_items_binding"

#Depends on BindCommandHandler and TableColumnPropertiesDataBindingCommandHandler
class TableItemsDataBindingCommandHandler
  include CommandHandler

  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(GWidget) and
    parent.widget.is_a?(Table) and
    command_symbol.to_s == "items" and
    args.size == 2 and
    args[0].is_a?(ModelBinding) and
    args[0].evaluate_property.is_a?(Array) and
    args[1].is_a?(Array) and
    block == nil
  end

  def do_handle(parent, command_symbol, *args, &block)
    model_binding = args[0]
    column_properties = args[1]
    TableItemsBinding.new(parent, model_binding, column_properties)
  end

end
