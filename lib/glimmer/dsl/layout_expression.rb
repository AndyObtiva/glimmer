require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_layout"

module Glimmer
  module SWT
    module CommandHandlers
      class LayoutCommandHandler
        include CommandHandler

        include_package 'org.eclipse.swt.widgets'
        include_package 'org.eclipse.swt.layout'

        def can_handle?(parent, command_symbol, *args, &block)
          command_symbol.to_s.end_with?('_layout') &&
            (parent.is_a?(GWidget) || parent.is_a?(CustomWidget)) &&
            parent.widget.is_a?(Composite) &&
            GLayout.layout_exists?(command_symbol.to_s)
        end

        def do_handle(parent, command_symbol, *args, &block)
          Glimmer.logger.debug "Layout #{command_symbol} args are: #{args.inspect}"
          GLayout.new(command_symbol.to_s, parent.widget, args)
        end
      end
    end
  end
end
