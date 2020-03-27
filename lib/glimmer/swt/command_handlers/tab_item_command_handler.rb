require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_shell"
require File.dirname(__FILE__) + "/../g_tab_item_composite"

module Glimmer
  module SWT
    module CommandHandlers
      class TabItemCommandHandler
        include CommandHandler
        include Glimmer

        include_package 'org.eclipse.swt.widgets'

        def can_handle?(parent, command_symbol, *args, &block)
          initial_condition = (parent.is_a?(GWidget) || parent.is_a?(CustomWidget)) &&
            command_symbol.to_s == "tab_item"
          if initial_condition
            if parent.widget.is_a?(TabFolder)
              return true
            else
              Glimmer.logger.error "tab_item widget may only be used directly under a tab_folder widget!"
            end
          end
          false
        end

        def do_handle(parent, command_symbol, *args, &block)
          tab_item = GWidget.new(command_symbol.to_s, parent.widget, args)
          GTabItemComposite.new(tab_item, parent.widget, args)
        end
      end
    end
  end
end
