require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"

# Responsible for providing a readable keyword (command symbol) to capture
# and return tree properties for use in TreeItemsDataBindingCommandHandler
class TreePropertiesDataBindingCommandHandler
  include CommandHandler

  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(RWidget) and
    parent.widget.is_a?(Tree) and
    command_symbol.to_s == "tree_properties" and
    block == nil
  end

  def do_handle(parent, command_symbol, *args, &block)
    args
  end

end
