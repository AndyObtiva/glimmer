################################################################################
# Copyright (c) 2008 Annas Al Maleh.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#    Annas Al Maleh - initial API and implementation
################################################################################ 

require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"

class WidgetCommandHandler
  include CommandHandler
  
  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(RWidget) and 
      command_symbol.to_s != "shell" and
      (args.size == 0 or 
        (args.size == 1 and args[0].is_a?(Fixnum))) and
      RWidget.widget_exists?(command_symbol.to_s)
  end
  
  def do_handle(parent, command_symbol, *args, &block)
    style = args[0] if args.size == 1
    puts "style argument is: " + style.to_s
    RWidget.new(command_symbol.to_s, parent.widget, style)
  end
  
end