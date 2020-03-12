require_relative '../command_handler'
require_relative 'models/r_color'

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
    elsif parent.is_a?(RWidget)
      display = parent.widget.display
    else
      display = nil
    end
    RColor.new(display, *args)
  end
end
