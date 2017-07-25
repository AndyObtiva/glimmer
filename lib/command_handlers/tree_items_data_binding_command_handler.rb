require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"
require File.dirname(__FILE__) + "/models/tree_items_updater"

class TreeItemsDataBindingCommandHandler
  include CommandHandler

  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    (parent.is_a?(RWidget)) and
    (parent.widget.is_a?(Tree)) and
    (command_symbol.to_s == "items") and
    (args.size == 2) and
    (args[0].is_a?(ModelObserver)) and
    (!args[0].evaluate_property.is_a?(Array)) and
    (args[1].is_a?(Array) && !args[1].empty? && args[1].first.is_a?(Hash)) and
    (block == nil)
  end

  def do_handle(parent, command_symbol, *args, &block)
    model_observer = args[0]
    tree_properties = args[1]
    TreeItemsUpdater.new(parent, model_observer, tree_properties)
  end

end
