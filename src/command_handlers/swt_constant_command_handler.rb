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

class SwtConstantCommandHandler
  include CommandHandler
  
  include_package 'org.eclipse.swt'

  def can_handle?(parent, command_symbol, *args, &block)
      args.size == 0 and
      block == nil
  end
  
  def do_handle(parent, command_symbol, *args, &block)
    puts 'org.eclipse.swt.SWT::' + command_symbol.to_s.upcase
    eval 'org.eclipse.swt.SWT::' + command_symbol.to_s.upcase
  end
  
end