require_relative '../../command_handler'
require_relative '../g_color'

module Glimmer
  module SWT
    module CommandHandlers
      class ColorCommandHandler
        include CommandHandler

        include_package 'org.eclipse.swt.widgets'

        def can_handle?(parent, command_symbol, *args, &block)
          ['rgba', 'rgb'].include?(command_symbol.to_s) &&
            (3..5).include?(args.count)
        end

        def do_handle(parent, command_symbol, *args, &block)
          if args.first.is_a?(Display) || args.first.nil?
            display = args.delete_at(0)
          elsif parent.is_a?(GWidget) || parent.is_a?(CustomWidget)
            display = parent.widget.display
          else
            display = GDisplay.instance.display
          end
          GColor.new(display, *args)
        end
      end
    end
  end
end
