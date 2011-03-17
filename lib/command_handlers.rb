require File.dirname(__FILE__) + "/command_handler_chain_factory"
require File.dirname(__FILE__) + "/command_handlers/shell_command_handler"
require File.dirname(__FILE__) + "/command_handlers/widget_listener_command_handler"
require File.dirname(__FILE__) + "/command_handlers/bind_command_handler"
require File.dirname(__FILE__) + "/command_handlers/tab_item_command_handler"
require File.dirname(__FILE__) + "/command_handlers/combo_selection_data_binding_command_handler"
require File.dirname(__FILE__) + "/command_handlers/list_selection_data_binding_command_handler"
require File.dirname(__FILE__) + "/command_handlers/table_items_data_binding_command_handler"
require File.dirname(__FILE__) + "/command_handlers/table_column_properties_data_binding_command_handler"
require File.dirname(__FILE__) + "/command_handlers/data_binding_command_handler"
require File.dirname(__FILE__) + "/command_handlers/widget_method_command_handler"
require File.dirname(__FILE__) + "/command_handlers/widget_command_handler"

# edit to add more command handlers and extend Glimmer
CommandHandlerChainFactory.def_dsl(:swt,
  ShellCommandHandler.new,
  WidgetListenerCommandHandler.new,
  BindCommandHandler.new,
  TabItemCommandHandler.new,
  ComboSelectionDataBindingCommandHandler.new,
  ListSelectionDataBindingCommandHandler.new,
  TableItemsDataBindingCommandHandler.new,
  TableColumnPropertiesDataBindingCommandHandler.new,
  DataBindingCommandHandler.new,
  WidgetMethodCommandHandler.new,
  WidgetCommandHandler.new
)
