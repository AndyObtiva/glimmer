require 'set'

require 'glimmer/data_binding/observable'

module Glimmer
  module DataBinding
    # TODO prefix utility methods with double-underscore
    module ObservableArray
      include Observable

      def add_observer(observer, element_properties=nil)
        return observer if has_observer?(observer) && element_properties.nil?
        property_observer_list << observer
        [element_properties].flatten.compact.each do |property|
          each do |element|
            observer.observe(element, property)
          end
        end
        observer
      end

      def remove_observer(observer, element_properties=nil)
        property_observer_list.delete(observer)
        [element_properties].flatten.compact.each do |property|
          each do |element|
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
        property_observer_list.to_a.each(&:call)
      end
      
      def <<(element)
        super(element)
        notify_observers
      end
      
      def []=(index, value)
        old_value = self[index]
        unregister_dependent_observers(old_value)
        super(index, value)
        notify_observers
      end
      
      def delete(element)
        unregister_dependent_observers(element)
        super(element)
        notify_observers
      end
      
      def delete_at(index)
        old_value = self[index]
        unregister_dependent_observers(old_value)
        super(index)
        notify_observers
      end
      
      def clear
        each do |old_value|
          unregister_dependent_observers(old_value)
        end
        super()
        notify_observers
      end
      
      def unregister_dependent_observers(old_value)
        # TODO look into optimizing this
        return unless old_value.is_a?(ObservableModel) || old_value.is_a?(ObservableArray)
        property_observer_list.each do |observer|
          observer.unregister_dependents_with_observable(observer.registration_for(self), old_value)
        end
      end
    end
  end
end
