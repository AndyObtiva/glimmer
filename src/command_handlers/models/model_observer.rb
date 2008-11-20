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

class ModelObserver
  attr_reader :model, :property_name, :property_type
  @@property_type_converters = {
    :undefined => Proc.new { |value| value }, 
    :fixnum => Proc.new { |string_value| string_value.to_i }
    #TODO check what other types are needed
  }
  def initialize(model, property_name, property_type)
    property_type = :undefined unless property_type
    @model = model
    @property_name = property_name
    @property_type = property_type
  end
  def update(value)
    converted_value = @@property_type_converters[@property_type].call(value)
    @model.send(@property_name + "=", converted_value) unless evaluate_property == converted_value
  end
  def evaluate_property
    @model.send(@property_name)
  end
end
  
