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
        super(element).tap do
          notify_observers
        end
      end
      
      def []=(index, value)
        old_value = self[index]
        unregister_dependent_observers(old_value)
        super(index, value).tap do
          notify_observers
        end
      end
      
      def delete(element)
        unregister_dependent_observers(element)
        super(element).tap do
          notify_observers
        end
      end
      
      def delete_at(index)
        old_value = self[index]
        unregister_dependent_observers(old_value)
        super(index).tap do
          notify_observers
        end
      end
      
      def delete_if(&block)
        if block_given?
          old_array = Array.new(self)
          super(&block).tap do |new_array|
            (old_array - new_array).each {|element| unregister_dependent_observers(element)}
            notify_observers
          end
        else
          super
        end
      end
      
      def clear
        each do |old_value|
          unregister_dependent_observers(old_value)
        end
        super.tap do
          notify_observers
        end
      end
      
      def reverse!
        super.tap do
          notify_observers
        end
      end

      def collect!(&block)
        if block_given?
          each do |old_value|
            unregister_dependent_observers(old_value)
          end
          super(&block).tap do
            notify_observers
          end
        else
          super
        end
      end
      alias map! collect!

      def compact!
        super(&block).tap do
          notify_observers
        end
      end

      def flatten!(level=nil)
        each do |old_value|
          unregister_dependent_observers(old_value)
        end
        (level.nil? ? super : super(level)).tap do
          notify_observers
        end
      end

      def rotate!(count=1)
        super(count).tap do
          notify_observers
        end
      end

      def select!(&block)
        if block_given?
          old_array = Array.new(self)
          super(&block).tap do |new_array|
            (old_array - new_array).each do |old_value|
              unregister_dependent_observers(old_value)
            end
            notify_observers
          end
        else
          super
        end
      end

      def shuffle!(hash = nil)
        (hash.nil? ? super : super(random: hash[:random])).tap do
          notify_observers
        end
      end

      def slice!(arg1, arg2=nil)
        old_array = Array.new(self)
        (arg2.nil? ? super(arg1) : super(arg1, arg2)).tap do |new_array|
          (old_array - new_array).each do |old_value|
            unregister_dependent_observers(old_value)
          end
          notify_observers
        end
      end

      def sort!(&block)
        (block.nil? ? super : super(&block)).tap do
          notify_observers
        end
      end

      def sort_by!(&block)
        (block.nil? ? super : super(&block)).tap do
          notify_observers
        end
      end

      def uniq!(&block)
        (block.nil? ? super : super(&block)).tap do
          notify_observers
        end
      end

      def reject!(&block)
        if block_given?
          old_array = Array.new(self)
          super(&block).tap do |new_array|
            (old_array - new_array).each do |old_value|
              unregister_dependent_observers(old_value)
            end
            notify_observers
          end
        else
          super
        end
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
