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
    module ObservableHash
      include Observable

      class Notifier
        include Observer
        
        def initialize(observable_model, key)
          @observable_model = observable_model
          @key = key
        end
        
        def call(new_value=nil, *extra_args)
          @observable_model.notify_observers(@key)
        end
      end
      
      OBSERVED_STORE_METHOD = lambda do |key, value|
        if key_observer_list(key).empty?
          if all_key_observer_list.empty?
            self.send('__original__store', key, value)
          else
            old_value = self[key]
            unregister_dependent_observers(nil, old_value) # remove dependent observers previously installed in ensure_array_object_observer and ensure_hash_object_observer
            self.send('__original__store', key, value)
            notify_observers(key)
            ensure_array_object_observer(nil, value, old_value)
            ensure_hash_object_observer(nil, value, old_value)
          end
        else
          old_value = self[key]
          unregister_dependent_observers(key, old_value) # remove dependent observers previously installed in ensure_array_object_observer and ensure_hash_object_observer
          self.send('__original__store', key, value)
          notify_observers(key)
          ensure_array_object_observer(key, value, old_value)
          ensure_hash_object_observer(key, value, old_value)
        end
      end

      def add_observer(observer, key = nil)
        return observer if has_observer?(observer, key)
        key_observer_list(key) << observer
        add_key_writer_observer(key)
        observer
      end

      def remove_observer(observer, key = nil)
        if has_observer?(observer, key)
          key_observer_list(key).delete(observer)
          observer.unobserve(self, key)
        end
      end

      def remove_observers(key)
        key_observer_hash[key].each do |observer|
          remove_observer(observer, key)
        end
        key_observer_hash.delete(key)
      end

      def remove_all_observers
        all_observers = key_observer_hash.clone
        key_observer_hash.keys.each do |key|
          remove_observers(key)
        end
        key_observer_hash.clear
        all_observers
      end

      def has_observer?(observer, key = nil)
        key_observer_list(key).include?(observer)
      end

      def has_observer_for_any_key?(observer)
        key_observer_hash.values.map(&:to_a).reduce(:+).include?(observer)
      end

      def key_observer_hash
        @key_observers ||= Hash.new
      end

      def key_observer_list(key)
        key_observer_hash[key] = Concurrent::Set.new unless key_observer_hash[key]
        key_observer_hash[key]
      end
      
      def all_key_observer_list
        key_observer_list(nil)
      end
      
      def notify_observers(key)
        all_key_observer_list.to_a.each { |observer| observer.call(self[key], key) }
        (key_observer_list(key).to_a - all_key_observer_list.to_a).each { |observer| observer.call(self[key]) }
      end

      def add_key_writer_observer(key = nil)
        ensure_array_object_observer(key, self[key])
        ensure_hash_object_observer(key, self[key])
        begin
          method('__original__store')
        rescue
          define_singleton_method('__original__store', store_method)
          define_singleton_method('[]=', &OBSERVED_STORE_METHOD)
        end
      rescue => e
        #ignore writing if no key writer exists
        Glimmer::Config.logger.debug {"No need to observe store method: '[]='\n#{e.message}\n#{e.backtrace.join("\n")}"}
      end
      
      def store_method
        self.class.instance_method('[]=') rescue self.method('[]=')
      end

      def unregister_dependent_observers(key, old_value)
        # TODO look into optimizing this
        return unless old_value.is_a?(ObservableModel) || old_value.is_a?(ObservableArray) || old_value.is_a?(ObservableHash)
        key_observer_list(key).each { |observer| observer.unregister_dependents_with_observable(observer.registration_for(self, key), old_value) }
      end
      alias deregister_dependent_observers unregister_dependent_observers

      def ensure_array_object_observer(key, object, old_object = nil)
        return unless object&.is_a?(Array)
        array_object_observer = array_object_observer_for(key)
        array_observer_registration = array_object_observer.observe(object)
        key_observer_list(key).each do |observer|
          my_registration = observer.registration_for(self, key) # TODO eliminate repetition
          observer.add_dependent(my_registration => array_observer_registration)
        end
        array_object_observer_for(key).unregister(old_object) if old_object.is_a?(ObservableArray)
      end

      def array_object_observer_for(key)
        @array_object_observers ||= Concurrent::Hash.new
        @array_object_observers[key] = ObservableModel::Notifier.new(self, key) unless @array_object_observers.has_key?(key)
        @array_object_observers[key]
      end
      
      def ensure_hash_object_observer(key, object, old_object = nil)
        return unless object&.is_a?(Hash)
        hash_object_observer = hash_object_observer_for(key)
        hash_observer_registration = hash_object_observer.observe(object)
        key_observer_list(key).each do |observer|
          my_registration = observer.registration_for(self, key) # TODO eliminate repetition
          observer.add_dependent(my_registration => hash_observer_registration)
        end
        hash_object_observer_for(key).unregister(old_object) if old_object.is_a?(ObservableHash)
      end

      def hash_object_observer_for(key)
        @hash_object_observers ||= Concurrent::Hash.new
        @hash_object_observers[key] = ObservableModel::Notifier.new(self, key) unless @hash_object_observers.has_key?(key)
        @hash_object_observers[key]
      end
    end
  end
end
