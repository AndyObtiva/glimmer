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
    class ModelBinding
      include Observable
      include Observer

      attr_reader :binding_options, :property_name_expression

      def initialize(base_model, property_name_expression, binding_options = nil)
        @base_model = base_model
        @property_name_expression = property_name_expression
        @binding_options = binding_options || Concurrent::Hash.new
        if computed?
          @computed_model_bindings = computed_by.map do |computed_by_property_expression|
            self.class.new(base_model, computed_by_property_expression)
          end
        end
      end

      def model
        nested_property? ? nested_model : base_model
      end

      # e.g. person.address.state returns [person, person.address]
      def nested_models
        @nested_models = [base_model]
        model_property_names.reduce(base_model) do |reduced_model, nested_model_property_name|
          if reduced_model.nil?
            nil
          else
            invoke_property_reader(reduced_model, nested_model_property_name).tap do |new_reduced_model|
              @nested_models << new_reduced_model
            end
          end
        end
        @nested_models
      end

      def nested_model
        nested_models.last
      end

      def base_model
        @base_model
      end

      def property_name
        nested_property? ? nested_property_name : property_name_expression
      end

      def convert_on_read(value)
        apply_converter(@binding_options[:on_read], value)
      end

      def convert_on_write(value)
        apply_converter(@binding_options[:on_write], value)
      end

      def apply_converter(converter, value)
        return value if converter.nil?
        return value.send(converter) if (converter.is_a?(String) || converter.is_a?(Symbol)) && value.respond_to?(converter)
        return converter.call(value) if converter.respond_to?(:call, value)
        raise Glimmer::Error, "Unsupported bind converter: #{converter.inspect}"
      end

      # All nested property names
      # e.g. property name expression "address.state" gives ['address', 'state']
      # If there are any indexed property names, this returns indexes as properties.
      # e.g. property name expression "addresses[1].state" gives ['addresses', '[1]', 'state']
      def nested_property_names
        @nested_property_names ||= property_name_expression.split(".").map {|pne| pne.match(/([^\[]+)(\[[^\]]+\])?/).to_a.drop(1)}.flatten.compact
      end

      # Final nested property name
      # e.g. property name expression "address.state" gives :state
      def nested_property_name
        nested_property_names.last
      end

      # Model representing nested property names
      # e.g. property name expression "address.state" gives [:address]
      def model_property_names
        nested_property_names[0...-1]
      end

      def nested_property?
        property_name_expression.match(/[.\[]/)
      end

      def computed?
        !computed_by.empty?
      end

      def computed_by
        [@binding_options[:computed_by]].flatten.compact
      end

      def nested_property_observers_for(observer)
        @nested_property_observers_collection ||= Concurrent::Hash.new
        unless @nested_property_observers_collection.has_key?(observer)
          @nested_property_observers_collection[observer] = nested_property_names.reduce(Concurrent::Hash.new) do |output, property_name|
            output.merge(
              property_name => Observer.proc do |new_value|
                # Ensure reattaching observers when a higher level nested property is updated (e.g. person.address changes reattaches person.address.street observer)
                add_observer(observer)
                observer.call(evaluate_property)
              end
            )
          end
        end
        @nested_property_observers_collection[observer]
      end

      def add_observer(observer)
        if computed?
          add_computed_observers(observer)
        elsif nested_property?
          add_nested_observers(observer)
        else
          model_binding_observer = Observer.proc do |new_value|
            observer.call(evaluate_property)
          end
          observer_registration = model_binding_observer.observe(model, property_name)
          my_registration = observer.registration_for(self)
          observer.add_dependent(my_registration => observer_registration)
        end
      end

      def remove_observer(observer)
        if computed?
          @computed_model_bindings.each do |computed_model_binding|
            computed_observer_for(observer).unobserve(computed_model_binding)
          end
          @computed_observer_collection.delete(observer)
        elsif nested_property?
          nested_property_observers_for(observer).clear
        else
          observer.unobserve(model, property_name)
        end
      end

      def computed_observer_for(observer)
        @computed_observer_collection ||= Concurrent::Hash.new
        unless @computed_observer_collection.has_key?(observer)
          @computed_observer_collection[observer] = Observer.proc do |new_value|
            observer.call(evaluate_property)
          end
        end
        @computed_observer_collection[observer]
      end

      def add_computed_observers(observer)
        @computed_model_bindings.each do |computed_model_binding|
          observer_registration = computed_observer_for(observer).observe(computed_model_binding)
          my_registration = observer.registration_for(self)
          observer.add_dependent(my_registration => observer_registration)
        end
      end

      def add_nested_observers(observer)
        nested_property_observers = nested_property_observers_for(observer)
        nested_models.zip(nested_property_names).each_with_index do |zip, i|
          model, property_name = zip
          nested_property_observer = nested_property_observers[property_name]
          previous_index = i - 1
          if previous_index.negative?
            parent_model = self
            parent_property_name = nil
            parent_observer = observer
          else
            parent_model = nested_models[previous_index]
            parent_property_name = nested_property_names[previous_index]
            parent_observer = nested_property_observers[parent_property_name]
          end
          parent_property_name = nil if parent_property_name.to_s.start_with?('[')
          unless model.nil?
            # TODO figure out a way to deal with this more uniformly
            observer_registration = property_indexed?(property_name) ? nested_property_observer.observe(model) : nested_property_observer.observe(model, property_name)
            parent_registration = parent_observer.registration_for(parent_model, parent_property_name)
            parent_observer.add_dependent(parent_registration => observer_registration)
          end
        end
      end

      def call(value)
        return if model.nil?
        converted_value = value
        invoke_property_writer(model, "#{property_name}=", converted_value) unless converted_value == evaluate_property
      end

      def evaluate_property
        value = nil
        value = invoke_property_reader(model, property_name) unless model.nil?
        convert_on_read(value)
      end

      def evaluate_options_property
        model.send(options_property_name) unless model.nil?
      end

      def options_property_name
        self.property_name + "_options"
      end

      def property_indexed?(property_expression)
        property_expression.to_s.start_with?('[')
      end

      def invoke_property_reader(object, property_expression)
        if property_indexed?(property_expression)
          property_method = '[]'
          property_argument = property_expression[1...-1]
          property_argument = property_argument.to_i if property_argument.match(/\d+/)
          object.send(property_method, property_argument)
        else
          object.send(property_expression)
        end
      end

      def invoke_property_writer(object, property_expression, value)
        raise "Cannot invoke `#{property_expression}` because ModelBinding#binding_options[:read_only]=true" if @binding_options[:read_only]
        value = convert_on_write(value)
        if property_indexed?(property_expression)
          property_method = '[]='
          property_argument = property_expression[1...-2]
          property_argument = property_argument.to_i if property_argument.match(/\d+/)
          object.send(property_method, property_argument, value)
        else
          object.send(property_expression, value)
        end
      end
    end
  end
end
