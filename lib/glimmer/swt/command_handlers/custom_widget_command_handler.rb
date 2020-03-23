require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../custom_widget"
require File.dirname(__FILE__) + "/../g_widget"

module Glimmer
  module SWT
    module CommandHandlers
      class CustomWidgetCommandHandler
        include CommandHandler

        def can_handle?(parent, command_symbol, *args, &block)
          (parent.is_a?(GWidget) || parent.is_a?(SWT::CustomWidget)) and
          SWT::CustomWidget.for(command_symbol)
        end

        def do_handle(parent, command_symbol, *args, &block)
          options = args.pop if args.last.is_a?(Hash)
          Glimmer.logger.debug "Custom widget #{command_symbol} styles are: [" + args.inspect + "] and options are: #{options}"
          SWT::CustomWidget.for(command_symbol).new(parent, *args, options, &block)
        end
      end
    end
  end
end
