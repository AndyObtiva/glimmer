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
require File.dirname(__FILE__) + "/models/r_shell"

class ShellCommandHandler
  include CommandHandler
  
  def can_handle?(parent, command_symbol, *args, &block)
    command_symbol.to_s == "shell"
  end
  
  def do_handle(parent, command_symbol, *args, &block) 
    RShell.send(:new, *args)
  end
  
end