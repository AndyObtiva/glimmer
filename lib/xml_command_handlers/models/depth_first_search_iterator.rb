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

class DepthFirstSearchIterator
  def initialize(node, node_visitor)
    @node = node
    @node_visitor = node_visitor
  end
  
  def iterate
    process(@node)
  end
  
  def process(node)
    @node_visitor.process_before_children(node)
    node.children.each { |child| process(child) } unless node.is_a?(String)
    @node_visitor.process_after_children(node)
  end
  
end
