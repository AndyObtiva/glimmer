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

require File.dirname(__FILE__) + "/command_handler_chain_link"

class CommandHandlerChainFactory
  @@last_chain_link = nil
  @@chain = nil
  
  def self.set_command_handlers(*command_handler_array)
    command_handler_array.each do |command_handler|
      puts "Loading #{command_handler.class.to_s}..."
      chain_link = CommandHandlerChainLink.new(command_handler)
      @@last_chain_link.chain_to(chain_link) if @@last_chain_link
      @@last_chain_link = chain_link
      @@chain = chain_link unless @@chain
    end
  end
  
  def self.chain
    @@chain
  end
end