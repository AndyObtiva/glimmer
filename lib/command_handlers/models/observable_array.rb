require 'set'

require_relative 'observable'

# TODO prefix utility methods with double-underscore
module ObservableArray
  include Observable

  def add_observer(observer, element_properties=nil)
    property_observer_list << observer
    [element_properties].flatten.compact.each do |property|
      each do |element|
        element.extend(ObservableModel) unless element.is_a?(ObservableModel)
        observer.observe(element, property)
      end
    end
    observer
  end

  def remove_observer(observer, element_properties=nil)
    property_observer_list.delete(observer)
    [element_properties].flatten.compact.each do |property|
      each do |element|
        element.extend(ObservableModel) unless element.is_a?(ObservableModel)
        observer.unobserve(element, property)
      end
    end
    observer
  end

  def has_observer?(observer)
    property_observer_list.include?(observer)
  end

  def property_observer_list
    @property_observer_list ||= Set.new
  end

  def notify_observers
    property_observer_list.each {|observer| observer.update}
  end

  def self.extend_object(array)
    array.instance_eval("alias __original_add <<")
    array.instance_eval <<-end_eval, __FILE__, __LINE__
      def <<(value)
        self.__original_add(value)
        notify_observers
      end
    end_eval

    array.instance_eval("alias __original_set_value []=")
    array.instance_eval <<-end_eval, __FILE__, __LINE__
      def []=(index, value)
        old_value = self[index]
        unregister_dependent_observers(old_value)
        self.__original_set_value(index, value)
        notify_observers
      end
    end_eval

    array.instance_eval("alias __original_delete delete")
    array.instance_eval <<-end_eval, __FILE__, __LINE__
      def delete(value)
        unregister_dependent_observers(value)
        self.__original_delete(value)
        notify_observers
      end
    end_eval

    array.instance_eval("alias __original_delete_at delete_at")
    array.instance_eval <<-end_eval, __FILE__, __LINE__
      def delete_at(index)
        old_value = self[index]
        unregister_dependent_observers(old_value)
        self.__original_delete_at(index)
        notify_observers
      end
    end_eval

    array.instance_eval("alias __original_clear clear")
    array.instance_eval <<-end_eval, __FILE__, __LINE__
      def clear
        each do |old_value|
          unregister_dependent_observers(old_value)
        end
        self.__original_clear
        notify_observers
      end
    end_eval

    super
  end

  def unregister_dependent_observers(old_value)
    # TODO look into optimizing this
    return unless old_value.is_a?(ObservableModel) || old_value.is_a?(ObservableArray)
    property_observer_list.each do |observer|
      observer.unregister_dependents_with_observable([self, nil], old_value)
    end
  end

end
