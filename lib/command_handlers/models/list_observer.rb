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
  @@property_type_updaters = {
    :string => lambda { |widget, value| widget.widget.select(widget.widget.index_of(value.to_s)) }, 
    :array => lambda { |widget, value| widget.widget.selection=((value or []).to_java :string) }
  }
  @@property_evaluators = {
    :string => lambda do |selection_array|     
      return nil if selection_array.empty?
      selection_array[0]
     end, 
    :array => lambda do |selection_array| 
      selection_array
    end
  }
  def initialize(widget, property_type)
    property_type = :string if property_type.nil? or property_type == :undefined
    @widget = widget
    @property_type = property_type
  end
  def update(value)
    raise "hell" if value == ["Canada"]
    @@property_type_updaters[@property_type].call(@widget, value) unless evaluate_property == value
  end
  def evaluate_property
    selection_array = @widget.widget.send("selection").to_a
    property_value = @@property_evaluators[@property_type].call(selection_array)
    return property_value
  end
end
  
