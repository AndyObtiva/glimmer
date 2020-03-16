require_relative "command_handler_chain_factory"
require_relative "command_handlers/color_command_handler"
require_relative "command_handlers/shell_command_handler"
require_relative "command_handlers/widget_listener_command_handler"
require_relative "command_handlers/bind_command_handler"
require_relative "command_handlers/tab_item_command_handler"
require_relative "command_handlers/combo_selection_data_binding_command_handler"
require_relative "command_handlers/list_selection_data_binding_command_handler"
require_relative "command_handlers/tree_items_data_binding_command_handler"
require_relative "command_handlers/tree_properties_data_binding_command_handler"
require_relative "command_handlers/table_items_data_binding_command_handler"
require_relative "command_handlers/table_column_properties_data_binding_command_handler"
require_relative "command_handlers/data_binding_command_handler"
require_relative "command_handlers/widget_method_command_handler"
require_relative "command_handlers/widget_command_handler"

module Glimmer  
  # edit to add more command handlers and extend Glimmer
  CommandHandlerChainFactory.def_dsl(:swt,
    ShellCommandHandler.new,
    WidgetListenerCommandHandler.new,
    BindCommandHandler.new,
    TabItemCommandHandler.new,
    ComboSelectionDataBindingCommandHandler.new,
    ListSelectionDataBindingCommandHandler.new,
    TreeItemsDataBindingCommandHandler.new,
    TreePropertiesDataBindingCommandHandler.new,
    TableItemsDataBindingCommandHandler.new,
    TableColumnPropertiesDataBindingCommandHandler.new,
    DataBindingCommandHandler.new,
    ColorCommandHandler.new,
    WidgetMethodCommandHandler.new,
    WidgetCommandHandler.new
  )
end
