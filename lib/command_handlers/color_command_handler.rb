require_relative '../command_handler'
require_relative 'models/r_color'

class ColorCommandHandler
  include CommandHandler

  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(RWidget) and
      ['rgba', 'rgb'].include?(command_symbol.to_s) and
      (3..4).include?(args.count)
  end

  def do_handle(parent, command_symbol, *args, &block)
    RColor.new(parent.widget.display, *args).color
  end
end
