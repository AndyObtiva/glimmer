# Copyright (c) 2007-2022 Andy Maleh
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

require 'glimmer/data_binding/observable_hashable'
require 'glimmer/data_binding/observer'

module Glimmer
  module DataBinding
    module ObservableHash
      include ObservableHashable

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
      
      def add_observer(observer, key = nil, options = {})
        if key.is_a?(Hash)
          options = key
          key = nil
        end
        return observer if has_observer?(observer, key)
        key_observer_list(key) << observer
        add_key_writer_observer(key, options)
        observer
      end

      def remove_observer(observer, key = nil, options = {})
        old_value = self[key]
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
        @key_observers ||= Concurrent::Hash.new
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
        (key_observer_list(key).to_a - all_key_observer_list.to_a).each { |observer| observer.call(self[key], key) }
      end

      def unregister_dependent_observers(key, old_value)
        # TODO look into optimizing this
        return unless old_value.is_a?(ObservableModel) || old_value.is_a?(ObservableArray) || old_value.is_a?(ObservableHash)
        key_observer_list(key).each { |observer| observer.unregister_dependents_with_observable(observer.registration_for(self, key), old_value) }
      end
      alias deregister_dependent_observers unregister_dependent_observers

      def ensure_array_object_observer(key, object, old_object = nil, options = {})
        options ||= {}
        return unless object&.is_a?(Array)
        array_object_observer = array_object_observer_for(key)
        array_observer_registration = array_object_observer.observe(object, options)
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
      
      def delete(key, &block)
        old_value = self[key]
        unless old_value.nil?
          unregister_dependent_observers(key, old_value)
          unregister_dependent_observers(nil, old_value)
        end
        super(key, &block).tap do
          notify_observers(key) unless old_value.nil?
        end
      end
      
      def delete_if(&block)
        if block_given?
          old_hash = self.dup
          super(&block).tap do |new_hash|
            deleted_keys = old_hash.keys - new_hash.keys
            deleted_keys.each do |deleted_key|
              deleted_value = old_hash[deleted_key]
              unless deleted_value.nil?
                unregister_dependent_observers(deleted_key, deleted_value)
                unregister_dependent_observers(nil, deleted_value)
                notify_observers(deleted_key)
              end
            end
          end
        else
          super
        end
      end
      
      def select!(&block)
        if block_given?
          old_hash = self.dup
          super(&block).tap do |new_hash|
            deleted_keys = old_hash.keys - new_hash.keys
            deleted_keys.each do |deleted_key|
              deleted_value = old_hash[deleted_key]
              unless deleted_value.nil?
                unregister_dependent_observers(deleted_key, deleted_value)
                unregister_dependent_observers(nil, deleted_value)
                notify_observers(deleted_key)
              end
            end
          end
        else
          super
        end
      end
      
      def filter!(&block)
        if block_given?
          old_hash = self.dup
          super(&block).tap do |new_hash|
            deleted_keys = old_hash.keys - new_hash.keys
            deleted_keys.each do |deleted_key|
              deleted_value = old_hash[deleted_key]
              unless deleted_value.nil?
                unregister_dependent_observers(deleted_key, deleted_value)
                unregister_dependent_observers(nil, deleted_value)
                notify_observers(deleted_key)
              end
            end
          end
        else
          super
        end
      end
      
      def keep_if(&block)
        if block_given?
          old_hash = self.dup
          super(&block).tap do |new_hash|
            deleted_keys = old_hash.keys - new_hash.keys
            deleted_keys.each do |deleted_key|
              deleted_value = old_hash[deleted_key]
              unless deleted_value.nil?
                unregister_dependent_observers(deleted_key, deleted_value)
                unregister_dependent_observers(nil, deleted_value)
                notify_observers(deleted_key)
              end
            end
          end
        else
          super
        end
      end
      
      def reject!(&block)
        if block_given?
          old_hash = self.dup
          super(&block).tap do |new_hash|
            deleted_keys = old_hash.keys - new_hash.keys
            deleted_keys.each do |deleted_key|
              deleted_value = old_hash[deleted_key]
              unless deleted_value.nil?
                unregister_dependent_observers(deleted_key, deleted_value)
                unregister_dependent_observers(nil, deleted_value)
                notify_observers(deleted_key)
              end
            end
          end
        else
          super
        end
      end
      
      def shift
        old_hash = self.dup
        super.tap do
          new_hash = self
          deleted_keys = old_hash.keys - new_hash.keys
          deleted_keys.each do |deleted_key|
            deleted_value = old_hash[deleted_key]
            unless deleted_value.nil?
              unregister_dependent_observers(deleted_key, deleted_value)
              unregister_dependent_observers(nil, deleted_value)
              notify_observers(deleted_key)
            end
          end
        end
      end
      
      def merge!(*other_hashes, &block)
        if other_hashes.empty?
          super
        else
          old_hash = self.dup
          super(*other_hashes, &block).tap do |new_hash|
            changed_keys = other_hashes.map(&:keys).reduce(:+)
            changed_keys.each do |changed_key|
              old_value = old_hash[changed_key]
              if new_hash[changed_key] != old_value
                unregister_dependent_observers(changed_key, old_value)
                unregister_dependent_observers(nil, old_value)
                notify_observers(changed_key)
              end
            end
          end
        end
      end
      
      def replace(other_hash)
        old_hash = self.dup
        super(other_hash).tap do |new_hash|
          changed_keys = old_hash.keys + new_hash.keys
          changed_keys.each do |changed_key|
            old_value = old_hash[changed_key]
            if new_hash[changed_key] != old_value
              unregister_dependent_observers(changed_key, old_value)
              unregister_dependent_observers(nil, old_value)
              notify_observers(changed_key)
            end
          end
        end
      end
      
      def transform_keys!(hash2 = nil, &block)
        if hash2.nil? && block.nil?
          super
        else
          old_hash = self.dup
          result = hash2.nil? ? super(&block) : super(hash2, &block)
          result.tap do |new_hash|
            changed_keys = old_hash.keys + new_hash.keys
            changed_keys.each do |changed_key|
              old_value = old_hash[changed_key]
              if new_hash[changed_key] != old_value
                unregister_dependent_observers(changed_key, old_value)
                unregister_dependent_observers(nil, old_value)
                notify_observers(changed_key)
              end
            end
          end
        end
      end
      
      def transform_values!(&block)
        if block_given?
          old_hash = self.dup
          super(&block).tap do |new_hash|
            new_hash.keys.each do |changed_key|
              old_value = old_hash[changed_key]
              if new_hash[changed_key] != old_value
                unregister_dependent_observers(changed_key, old_value)
                unregister_dependent_observers(nil, old_value)
                notify_observers(changed_key)
              end
            end
          end
        else
          super
        end
      end
    end
  end
end
