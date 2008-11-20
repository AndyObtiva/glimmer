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
require File.dirname(__FILE__) + "/models/depth_first_search_iterator"
require File.dirname(__FILE__) + "/models/name_space_visitor"

class XmlNameSpaceCommandHandler
  include CommandHandler, Glimmer
  
  def can_handle?(parent, command_symbol, *args, &block)
    (parent == nil or parent.is_a?(Node)) and
    (command_symbol.to_s == "name_space")
    (args.size == 1) and 
    (args[0].is_a?(Symbol)) and
    block
  end
  
  def do_handle(parent, command_symbol, *args, &block)
    node = block.call
    unless node.is_a?(String)
      name_space_visitor = NameSpaceVisitor.new(args[0].to_s)
      DepthFirstSearchIterator.new(node, name_space_visitor).iterate
      def node.process_block(block) 
      puts 'block'
        #NOOP
      end
    end
    parent.children << node if parent and !parent.children.include?(node)
    node
  end
  
end
