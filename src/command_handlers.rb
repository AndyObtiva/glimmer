################################################################################
# Copyright (c) 2008 Annas Al Maleh.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#    Annas Al Maleh - initial API and implementation
################################################################################ 

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
require File.dirname(__FILE__) + "/command_handlers/swt_constant_command_handler"

# edit to add more command handlers and extend Glimmer
CommandHandlerChainFactory.set_command_handlers(
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
  WidgetCommandHandler.new,
  SwtConstantCommandHandler.new #at the bottom to avoid stealing commands from other command handlers
)
