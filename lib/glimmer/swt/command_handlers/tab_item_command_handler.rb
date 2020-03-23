require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_shell"
require File.dirname(__FILE__) + "/../g_tab_item_composite"

module Glimmer
  module SWT
    module CommandHandlers
      class TabItemCommandHandler
        include CommandHandler
        include Glimmer

        def can_handle?(parent, command_symbol, *args, &block)
          parent.is_a?(GWidget) and
          command_symbol.to_s == "tab_item"
        end

        def do_handle(parent, command_symbol, *args, &block)
          tab_item = GWidget.new(command_symbol.to_s, parent.widget, args)
          GTabItemComposite.new(tab_item, parent.widget, args)
        end
      end
    end
  end
end
