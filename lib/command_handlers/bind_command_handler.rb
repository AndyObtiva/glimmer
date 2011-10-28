require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"
require File.dirname(__FILE__) + "/models/model_observer"

class BindCommandHandler
  include CommandHandler

  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(RWidget) and
    command_symbol.to_s == "bind" and
    (((args.size == 2) and
    (args[1].is_a?(Symbol) or args[1].is_a?(String))) or
    ((args.size == 3) and
    (args[1].is_a?(Symbol) or args[1].is_a?(String)) and
    (args[2].is_a?(Symbol) or args[2].is_a?(String)))) and
    block == nil
  end

  def do_handle(parent, command_symbol, *args, &block)
    property_type = args[2] if (args.size == 3)
    ModelObserver.new(args[0], args[1].to_s, property_type)
  end

end