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
