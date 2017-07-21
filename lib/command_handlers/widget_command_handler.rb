require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"

class WidgetCommandHandler
  include CommandHandler
  
  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(RWidget) and 
      command_symbol.to_s != "shell" and
      RWidget.widget_exists?(command_symbol.to_s)
  end
  
  def do_handle(parent, command_symbol, *args, &block)
    Glimmer.logger.debug "widget styles are: " + args.inspect
    RWidget.new(command_symbol.to_s, parent.widget, args)
  end
  
end