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

class WidgetObserver
  attr_reader :widget, :property
  @@property_type_converters = {
    :text => Proc.new { |value| value.to_s },
    :items => Proc.new { |value| value.to_java :string}
  }
  def initialize model, property
    @widget = model
    @property = property
  end
  def update(value)
    converted_value = value
    converter = @@property_type_converters[@property.to_sym]
    converted_value = converter.call(value) if converter
    @widget.widget.send("set#{@property.camelcase(:upper)}", converted_value) unless evaluate_property == converted_value
  end
  def evaluate_property
    @widget.widget.send(@property)
  end
end
  
