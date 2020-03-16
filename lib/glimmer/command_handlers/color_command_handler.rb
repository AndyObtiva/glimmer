require_relative '../command_handler'
require_relative 'models/g_color'

module Glimmer
  class ColorCommandHandler
    include CommandHandler

    include_package 'org.eclipse.swt.widgets'

    def can_handle?(parent, command_symbol, *args, &block)
      ['rgba', 'rgb'].include?(command_symbol.to_s) and
      (3..5).include?(args.count)
    end

    def do_handle(parent, command_symbol, *args, &block)
      if args.first.is_a?(Display)
        display = args.delete_at(0)
      elsif parent.is_a?(GWidget)
        display = parent.widget.display
      else
        display = nil
      end
      GColor.new(display, *args)
    end
  end
end
