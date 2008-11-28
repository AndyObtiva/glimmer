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

class ListObserver
  attr_reader :widget
  def initialize widget
    @widget = widget
  end
  def update(value)
    value = value.to_s
    @widget.widget.select(@widget.widget.index_of(value)) unless evaluate_property == value
  end
  def evaluate_property
    selection_array = @widget.widget.send("selection")
    return nil if selection_array.to_a.empty?
    selection_array[0]
  end
end
  
