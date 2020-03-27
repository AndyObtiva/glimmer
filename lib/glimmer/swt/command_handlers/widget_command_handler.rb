require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../custom_widget"
require File.dirname(__FILE__) + "/../g_widget"

module Glimmer
  module SWT
    module CommandHandlers
      class WidgetCommandHandler
        include CommandHandler

        include_package 'org.eclipse.swt.widgets'
        include_package 'org.eclipse.swt.browser'

        def can_handle?(parent, command_symbol, *args, &block)
          (parent.is_a?(GWidget) || parent.is_a?(CustomWidget)) and
          command_symbol.to_s != "shell" and
          GWidget.widget_exists?(command_symbol.to_s)
        end

        def do_handle(parent, command_symbol, *args, &block)
          Glimmer.logger.debug "widget styles are: " + args.inspect
          GWidget.new(command_symbol.to_s, parent.widget, args)
        end
      end
    end
  end
end
