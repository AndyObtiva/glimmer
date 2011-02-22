require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/node"

class XmlTextCommandHandler
  include CommandHandler
  
  def can_handle?(parent, command_symbol, *args, &block)
    (parent == nil or parent.is_a?(Node)) and
    (command_symbol.to_s == "text") and
    ((args.size == 1) and (args[0].is_a?(String))) and
    !block
  end
  
  def do_handle(parent, command_symbol, *args, &block)
    parent.children << args[0] if parent
    args[0]
  end
  
end
