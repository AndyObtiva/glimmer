# Copyright (c) 2007-2021 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'glimmer/data_binding/observable'
require 'glimmer/data_binding/observer'

module Glimmer
  module DataBinding
    module ObservableModel
      include Observable

      class Notifier
        include Observer
        
        def initialize(observable_model, property_name)
          @observable_model = observable_model
          @property_name = property_name
        end
        
        def call(new_value=nil, *extra_args)
          @observable_model.notify_observers(@property_name)
        end
      end
      
      PROPERTY_WRITER_FACTORY = lambda do |property_name|
        property_writer_name = "#{property_name}="
        lambda do |value|
          old_value = self.send(property_name)
          unregister_dependent_observers(property_name, old_value) # remove dependent observers previously installed in ensure_array_object_observer and ensure_hash_object_observer
          self.send("__original__#{property_writer_name}", value)
          notify_observers(property_name)
          ensure_array_object_observer(property_name, value, old_value)
          ensure_hash_object_observer(property_name, value, old_value)
        end
      end

      def add_observer(observer, property_name)
        return observer if has_observer?(observer, property_name)
        property_observer_list(property_name) << observer
        add_property_writer_observers(property_name)
        observer
      end

      def remove_observer(observer, property_name)
        if has_observer?(observer, property_name)
          property_observer_list(property_name).delete(observer)
          observer.unobserve(self, property_name)
        end
      end

      def remove_observers(property_name)
        property_observer_hash[property_name.to_sym].each do |observer|
          remove_observer(observer, property_name)
        end
        property_observer_hash.delete(property_name.to_sym)
      end

      def remove_all_observers
        all_observers = property_observer_hash.clone
        property_observer_hash.keys.each do |property_name|
          remove_observers(property_name)
        end
        property_observer_hash.clear
        all_observers
      end

      def has_observer?(observer, property_name)
        property_observer_list(property_name).include?(observer)
      end

      def has_observer_for_any_property?(observer)
        property_observer_hash.values.map(&:to_a).reduce(:+).include?(observer)
      end

      def property_observer_hash
        @property_observers ||= Hash.new
      end

      def property_observer_list(property_name)
        property_observer_hash[property_name.to_sym] = Concurrent::Set.new unless property_observer_hash[property_name.to_sym]
        property_observer_hash[property_name.to_sym]
      end

      def notify_observers(property_name)
        property_observer_list(property_name).to_a.each { |observer| observer.call(send(property_name)) }
      end

      def add_property_writer_observers(property_name)
        property_writer_name = "#{property_name}="
        method(property_writer_name)
        ensure_array_object_observer(property_name, send(property_name))
        ensure_hash_object_observer(property_name, send(property_name))
        begin
          method("__original__#{property_writer_name}")
        rescue
          define_singleton_method("__original__#{property_writer_name}", property_writer_method(property_writer_name))
          define_singleton_method(property_writer_name, &PROPERTY_WRITER_FACTORY.call(property_name))
        end
      rescue => e
        #ignore writing if no property writer exists
        Glimmer::Config.logger.debug {"No need to observe property writer: #{property_writer_name}\n#{e.message}\n#{e.backtrace.join("\n")}"}
      end
      
      def property_writer_method(property_writer_name)
        self.class.instance_method(property_writer_name) rescue self.method(property_writer_name)
      end

      def unregister_dependent_observers(property_name, old_value)
        # TODO look into optimizing this
        return unless old_value.is_a?(ObservableModel) || old_value.is_a?(ObservableArray)
        property_observer_list(property_name).each { |observer| observer.unregister_dependents_with_observable(observer.registration_for(self, property_name), old_value) }
      end
      alias deregister_dependent_observers unregister_dependent_observers

      def ensure_array_object_observer(property_name, object, old_object = nil)
        return unless object&.is_a?(Array)
        array_object_observer = array_object_observer_for(property_name)
        array_observer_registration = array_object_observer.observe(object)
        property_observer_list(property_name).each do |observer|
          my_registration = observer.registration_for(self, property_name) # TODO eliminate repetition
          observer.add_dependent(my_registration => array_observer_registration)
        end
        array_object_observer_for(property_name).unregister(old_object) if old_object.is_a?(ObservableArray)
      end

      def array_object_observer_for(property_name)
        @array_object_observers ||= Concurrent::Hash.new
        @array_object_observers[property_name] = Notifier.new(self, property_name) unless @array_object_observers.has_key?(property_name)
        @array_object_observers[property_name]
      end
      
      def ensure_hash_object_observer(property_name, object, old_object = nil)
        return unless object&.is_a?(Hash)
        hash_object_observer = hash_object_observer_for(property_name)
        hash_observer_registration = hash_object_observer.observe(object)
        property_observer_list(property_name).each do |observer|
          my_registration = observer.registration_for(self, property_name) # TODO eliminate repetition
          observer.add_dependent(my_registration => hash_observer_registration)
        end
        hash_object_observer_for(property_name).unregister(old_object) if old_object.is_a?(ObservableHash)
      end

      def hash_object_observer_for(property_name)
        @hash_object_observers ||= Concurrent::Hash.new
        @hash_object_observers[property_name] = Notifier.new(self, property_name) unless @hash_object_observers.has_key?(property_name)
        @hash_object_observers[property_name]
      end
    end
  end
end
