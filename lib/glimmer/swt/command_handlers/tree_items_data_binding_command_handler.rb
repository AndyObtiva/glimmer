require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_widget"
require File.dirname(__FILE__) + "/../tree_items_binding"

module Glimmer
  module SWT
    module CommandHandlers
      class TreeItemsDataBindingCommandHandler
        include CommandHandler

        include_package 'org.eclipse.swt.widgets'

        def can_handle?(parent, command_symbol, *args, &block)
          (parent.is_a?(GWidget)) and
          (parent.widget.is_a?(Tree)) and
          (command_symbol.to_s == "items") and
          (args.size == 2) and
          (args[0].is_a?(ModelBinding)) and
          (!args[0].evaluate_property.is_a?(Array)) and
          (args[1].is_a?(Array) && !args[1].empty? && args[1].first.is_a?(Hash)) and
          (block == nil)
        end

        def do_handle(parent, command_symbol, *args, &block)
          model_binding = args[0]
          tree_properties = args[1]
          TreeItemsBinding.new(parent, model_binding, tree_properties)
        end
      end
    end
  end
end
