require 'set'
module ObservableArray

  def add_observer(element_properties, observer)
    property_observer_list << observer
    each do |element|
      [element_properties].flatten.each do |property|
        element.extend(ObservableModel) unless element.is_a?(ObservableModel)
        element.add_observer(property, observer)
      end
    end
  end

  def property_observer_list
    @property_observer_list = Set.new unless @property_observer_list
    @property_observer_list
  end

  def notify_observers
    property_observer_list.each {|observer| observer.update}
  end

  def self.extend_object(array)
    array.instance_eval("alias original_add <<")
    array.instance_eval <<-end_eval, __FILE__, __LINE__
      def <<(value)
        self.original_add(value)
        notify_observers
      end
    end_eval

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
    model.instance_eval <<-end_eval, __FILE__, __LINE__
      def #{method}(#{arguments})
        self.original_#{method}(#{arguments})
        notify_observers
      end
    end_eval
  end

end
