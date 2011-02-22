require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/node"

class XmlCommandHandler
  include CommandHandler
  
  def can_handle?(parent, command_symbol, *args, &block)
    (parent == nil or parent.is_a?(Node)) and
    (args.size == 0 or ((args.size == 1) and ((args[0].is_a?(Hash)) or (args[0].is_a?(Hash)))))
  end
  
  def do_handle(parent, command_symbol, *args, &block)
    attributes = Hash.new
    attributes = args[0] if (args.size == 1) 
    Node.new(parent, command_symbol.to_s, attributes, &block)
  end
  
end
