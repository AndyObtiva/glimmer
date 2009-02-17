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

module CommandHandler
  def can_handle?(parent, command_symbol, *args, &block)
    raise "must be implemented by a class"
  end
  def do_handle(parent, command_symbol, *args, &block) 
    raise "must be implemented by a class"
  end
end