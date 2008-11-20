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

module ObservableArray
  
  def add_observer(element_properties, observer)
    property_observer_list << observer
    each do |element|
      element_properties.each do |property|
        element.extend(ObservableModel) unless element.is_a?(ObservableModel)
        element.add_observer(property, observer)
      end
    end
  end

  def property_observer_list
    @property_observer_list = [] unless @property_observer_list
    @property_observer_list
  end
  
  def notify_observers
    property_observer_list.each {|observer| observer.update}
  end
  
  def self.extend_object(array)
    array.instance_eval("alias original_add <<")
    array.instance_eval "def <<(value) \n self.original_add(value); notify_observers; \nend"
    
    notify_observers_on_invokation(array, "delete", 1)
    notify_observers_on_invokation(array, "delete_at", 1)
    notify_observers_on_invokation(array, "clear")
    
    super
  end
  
  def self.notify_observers_on_invokation(model, method, argument_count=0)
    model.instance_eval "alias original_#{method} #{method}\n"
    arguments = ""
    for index in 1..argument_count
      arguments += "argument" + index.to_s + ","
    end
    arguments = arguments[0..-2]
    model.instance_eval "def #{method}(#{arguments}) \n self.original_#{method}(#{arguments}); notify_observers; \nend"
  end

end
