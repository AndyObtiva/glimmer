require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../custom_widget"
require File.dirname(__FILE__) + "/../custom_shell"
require File.dirname(__FILE__) + "/../g_widget"

module Glimmer
  module SWT
    module CommandHandlers
      class CustomWidgetCommandHandler
        include CommandHandler

        def can_handle?(parent, command_symbol, *args, &block)
          custom_widget_class = CustomWidget.for(command_symbol)
          custom_widget_class &&
            (parent.is_a?(GWidget) || parent.is_a?(CustomWidget) || custom_widget_class.ancestors.include?(CustomShell))
        end

        def do_handle(parent, command_symbol, *args, &block)
          options = args.last.is_a?(Hash) ? args.pop : {}
          Glimmer.logger.debug "Custom widget #{command_symbol} styles are: [" + args.inspect + "] and options are: #{options}"
          CustomWidget.for(command_symbol).new(parent, *args, options, &block)
        end
      end
    end
  end
end
