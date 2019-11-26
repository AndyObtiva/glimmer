require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"
require File.dirname(__FILE__) + "/models/model_observer"

# Responsible for setting up the return value of the bind keyword (command symbol)
# as a ModelObserver. It is then used by another command handler like
# DataBindingCommandHandler for text and selection properties on Text and Spinner
# or TableItemsDataBindingCommandHandler for items in a Table
class BindCommandHandler
  include CommandHandler

  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    (
      parent.is_a?(RWidget) and
      command_symbol.to_s == "bind" and
      (
        (
          (args.size == 2) and
          (
            args[1].is_a?(Symbol) or
            args[1].is_a?(String)
          )
        ) or
        (
          (args.size == 3) and
          (args[1].is_a?(Symbol) or args[1].is_a?(String)) and
          (args[2].is_a?(Symbol) or args[2].is_a?(String) or args[2].is_a?(Hash))
        ) or
        (
          (args.size == 4) and
          (args[1].is_a?(Symbol) or args[1].is_a?(String)) and
          (args[2].is_a?(Symbol) or args[2].is_a?(String)) and
          (args[3].is_a?(Hash))
        )
      ) and
      block == nil
    )
  end

  def do_handle(parent, command_symbol, *args, &block)
    property_type = args[2] if (args.size == 3) && !args[2].is_a?(Hash)
    observer_options = args[2] if args[2].is_a?(Hash)
    observer_options = args[3] if args[3].is_a?(Hash)
    ModelObserver.new(args[0], args[1].to_s, property_type, observer_options)
  end

end
