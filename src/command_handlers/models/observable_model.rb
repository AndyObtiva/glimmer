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

module ObservableModel
  
  def add_observer(property_name, observer)
    property_observer_list(property_name) << observer
  end

  def property_observer_hash
    @property_observers = Hash.new unless @property_observers
    @property_observers
  end
  
  def property_observer_list(property_name)
    property_observer_hash[property_name.to_sym] = [] unless property_observer_hash[property_name.to_sym]
    property_observer_hash[property_name.to_sym]
  end
  
  def notify_observers(property_name)
    property_observer_list(property_name).each {|observer| observer.update(send(property_name))}
  end
  
  def self.extend_object(model)
    super
    model.methods.each do |method|
      setter_method_pattern = /^\w+=$/
      if (method.match(setter_method_pattern))
        getter_method = method[0, method.length - 1]
        model.instance_eval "alias original_#{method} #{method}\n"
        model.instance_eval "def #{method}(value) \n self.original_#{method}(value); notify_observers('#{getter_method}'); \nend"
      end
    end
  end
end
