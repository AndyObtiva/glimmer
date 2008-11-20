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

require File.dirname(__FILE__) + "/node_visitor"

class NameSpaceVisitor < NodeVisitor
  
  def initialize(name_space_name)
    @name_space_name = name_space_name
  end
  
  def process_before_children(node)
    return if node.is_a?(String)
    node.name_space = Node.new(nil, @name_space_name, nil) if node and !node.name_space
  end
  
  def process_after_children(node)
    #NOOP
  end
  
end