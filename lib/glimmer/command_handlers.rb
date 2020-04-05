require_relative "command_handler_chain_factory"
require_relative "swt/command_handlers/observe_command_handler"
require_relative "swt/command_handlers/color_command_handler"
require_relative "swt/command_handlers/display_command_handler"
require_relative "swt/command_handlers/shell_command_handler"
require_relative "swt/command_handlers/layout_command_handler"
require_relative "swt/command_handlers/layout_data_command_handler"
require_relative "swt/command_handlers/widget_listener_command_handler"
require_relative "swt/command_handlers/bind_command_handler"
require_relative "swt/command_handlers/tab_item_command_handler"
require_relative "swt/command_handlers/combo_selection_data_binding_command_handler"
require_relative "swt/command_handlers/list_selection_data_binding_command_handler"
require_relative "swt/command_handlers/tree_items_data_binding_command_handler"
require_relative "swt/command_handlers/tree_properties_data_binding_command_handler"
require_relative "swt/command_handlers/table_items_data_binding_command_handler"
require_relative "swt/command_handlers/table_column_properties_data_binding_command_handler"
require_relative "swt/command_handlers/data_binding_command_handler"
require_relative "swt/command_handlers/property_command_handler"
require_relative "swt/command_handlers/widget_command_handler"
require_relative "swt/command_handlers/custom_widget_command_handler"

# TODO move into SWT namespace
module Glimmer
  # edit to add more command handlers and extend Glimmer
  CommandHandlerChainFactory.setup(
    SWT::CommandHandlers::ObserveCommandHandler.new,
    SWT::CommandHandlers::DisplayCommandHandler.new,
    SWT::CommandHandlers::ShellCommandHandler.new,
    SWT::CommandHandlers::LayoutDataCommandHandler.new,
    SWT::CommandHandlers::LayoutCommandHandler.new,
    SWT::CommandHandlers::WidgetListenerCommandHandler.new,
    SWT::CommandHandlers::BindCommandHandler.new,
    SWT::CommandHandlers::TabItemCommandHandler.new,
    SWT::CommandHandlers::ComboSelectionDataBindingCommandHandler.new,
    SWT::CommandHandlers::ListSelectionDataBindingCommandHandler.new,
    SWT::CommandHandlers::TreeItemsDataBindingCommandHandler.new,
    SWT::CommandHandlers::TreePropertiesDataBindingCommandHandler.new,
    SWT::CommandHandlers::TableItemsDataBindingCommandHandler.new,
    SWT::CommandHandlers::TableColumnPropertiesDataBindingCommandHandler.new,
    SWT::CommandHandlers::DataBindingCommandHandler.new,
    SWT::CommandHandlers::ColorCommandHandler.new,
    SWT::CommandHandlers::PropertyCommandHandler.new,
    SWT::CommandHandlers::WidgetCommandHandler.new,
    SWT::CommandHandlers::CustomWidgetCommandHandler.new
  )
end
