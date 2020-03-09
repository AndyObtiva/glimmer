require 'set'
module ObservableArray

  def add_observer(element_properties, observer)
    add_array_observer(observer)
    each do |element|
      [element_properties].flatten.each do |property|
        element.extend(ObservableModel) unless element.is_a?(ObservableModel)
        element.add_observer(property, observer)
      end
    end
    observer
  end

  def remove_observer(element_properties, observer)
    remove_array_observer(observer)
    each do |element|
      [element_properties].flatten.each do |property|
        element.extend(ObservableModel) unless element.is_a?(ObservableModel)
        element.remove_observer(property, observer)
      end
    end
  end

  def add_array_observer(observer)
    property_observer_list << observer
    observer.register(self)
    observer
  end

  def remove_array_observer(observer)
    property_observer_list.delete(observer)
  end

  def has_array_observer?(observer)
    property_observer_list.include?(observer)
  end

  def property_observer_list
    @property_observer_list = Set.new unless @property_observer_list
    @property_observer_list
  end

  def notify_observers
    property_observer_list.each {|observer| observer.update}
  end

  def self.extend_object(array)
    array.instance_eval("alias __original_add__ <<")
    array.instance_eval <<-end_eval, __FILE__, __LINE__
      def <<(value)
        self.__original_add__(value)
        notify_observers
      end
    end_eval

    array.instance_eval("alias __original_set_value__ []=")
    array.instance_eval <<-end_eval, __FILE__, __LINE__
      def []=(index, value)
        self.__original_set_value__(index, value)
        notify_observers
      end
    end_eval

    notify_observers_on_invokation(array, "delete")
    notify_observers_on_invokation(array, "delete_at")
    notify_observers_on_invokation(array, "clear")

    super
  end

  def self.notify_observers_on_invokation(model, method)
    model.instance_eval "alias __original_#{method} #{method}\n"
    model.instance_eval <<-end_eval, __FILE__, __LINE__
      def #{method}(*args, &block)
        self.__original_#{method}(*args, &block)
        notify_observers
      end
    end_eval
  end

end
