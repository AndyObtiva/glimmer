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
  
  class Updater
    def initialize(property_name, observable_model)
      @property_name = property_name
      @observable_model = observable_model
    end
    def update
      @observable_model.notify_observers(@property_name)
    end
  end
  
  def self.extend_object(model)
    super
    model.methods.each do |method|
      self.add_method_observers(model, method)
    end
  end
  
  def self.add_method_observers(model, method)
    setter_method_pattern = /^\w+=$/
    if (method.match(setter_method_pattern))
      getter_method = method[0, method.length - 1]
      getter_value = model.send(getter_method)
      if (getter_value.is_a?(Array) and 
          !getter_value.is_a?(ObservableArray))
        getter_value.extend(ObservableArray)
        getter_value.add_observer([], Updater.new(getter_method, model))
      end
      model.instance_eval "alias original_#{method} #{method}\n"
      model.instance_eval <<-end_eval, __FILE__, __LINE__
        def #{method}(value) 
          self.original_#{method}(value)
          notify_observers('#{getter_method}')
          ObservableModel.add_method_observers(self, '#{method}') if (value.is_a?(Array))
        end
      end_eval
    end
  end
end
