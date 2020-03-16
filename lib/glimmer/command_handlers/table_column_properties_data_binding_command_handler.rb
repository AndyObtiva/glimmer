require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/g_widget"

# Responsible for providing a readable keyword (command symbol) to capture
# and return column properties for use in TreeItemsDataBindingCommandHandler
class TableColumnPropertiesDataBindingCommandHandler
  include CommandHandler

  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(GWidget) and
    parent.widget.is_a?(Table) and
    command_symbol.to_s == "column_properties" and
    block == nil
  end

  def do_handle(parent, command_symbol, *args, &block)
    args
  end

end
