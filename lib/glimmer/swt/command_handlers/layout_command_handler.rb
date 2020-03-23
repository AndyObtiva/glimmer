require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/g_layout"

module Glimmer
  class LayoutCommandHandler
    include CommandHandler

    include_package 'org.eclipse.swt.widgets'
    include_package 'org.eclipse.swt.layout'

    def can_handle?(parent, command_symbol, *args, &block)
      parent.is_a?(GWidget) and
        parent.widget.is_a?(Composite) and
        command_symbol.to_s.end_with?('_layout') and
        GLayout.layout_exists?(command_symbol.to_s)
    end

    def do_handle(parent, command_symbol, *args, &block)
      Glimmer.logger.debug "Layout #{command_symbol} args are: #{args.inspect}"
      GLayout.new(command_symbol.to_s, parent.widget, args)
    end
  end
end
