require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_shell"
require File.dirname(__FILE__) + "/models/r_tab_item_composite"

class TabItemCommandHandler
  include CommandHandler
  include Glimmer
  
  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(RWidget) and 
      command_symbol.to_s == "tab_item" and
      (args.size == 0 or 
        (args.size == 1 and args[0].is_a?(Fixnum)))
  end
  
  def do_handle(parent, command_symbol, *args, &block) 
    style = args[0] if args.size == 1
    tab_item = RWidget.new(command_symbol.to_s, parent.widget, style)
    RTabItemComposite.new(tab_item, parent.widget, style)
  end
  
end