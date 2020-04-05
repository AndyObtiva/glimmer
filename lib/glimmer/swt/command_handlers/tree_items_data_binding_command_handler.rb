require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_widget"
require File.dirname(__FILE__) + "/../custom_widget"
require File.dirname(__FILE__) + "/../tree_items_binding"

module Glimmer
  module SWT
    module CommandHandlers
      class TreeItemsDataBindingCommandHandler
        include CommandHandler

        include_package 'org.eclipse.swt.widgets'

        def can_handle?(parent, command_symbol, *args, &block)
          command_symbol.to_s == "items" &&
            block == nil &&
            (parent.is_a?(GWidget) || parent.is_a?(CustomWidget)) &&
            parent.widget.is_a?(Tree) &&
            args.size == 2 &&
            args[0].is_a?(ModelBinding) &&
            !args[0].evaluate_property.is_a?(Array) &&
            args[1].is_a?(Array) &&
            !args[1].empty? &&
            args[1].first.is_a?(Hash)
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
