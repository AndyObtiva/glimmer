require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_shell"
require File.dirname(__FILE__) + "/models/r_tab_item_composite"

class TabItemCommandHandler
  include CommandHandler
  include Glimmer
  
  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(RWidget) and 
      command_symbol.to_s == "tab_item"
  end
  
  def do_handle(parent, command_symbol, *args, &block) 
    tab_item = RWidget.new(command_symbol.to_s, parent.widget, args)
    RTabItemComposite.new(tab_item, parent.widget, args)
  end
  
end