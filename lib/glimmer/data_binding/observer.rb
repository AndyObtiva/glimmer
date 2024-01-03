# Copyright (c) 2007-2024 Andy Maleh
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

require 'glimmer/error'

module Glimmer
  module DataBinding
    # Mixin representing Observer trait from Observer Design Pattern
    # Allows classes to include without interfering with their
    # inheritance hierarchy.
    #
    # Includes a default implementation that can receive an observer block
    # Example: Observer.proc {|new_value| puts new_value}
    # Subclasses may override
    module Observer
      # Observer Proc default implementation that takes an observer block to process updates
      # via call method
      class Proc
        include Observer

        def initialize(&observer_block)
          @observer_block = observer_block
        end

        # Called by observables once updates occur sending in the new_value if any
        def call(new_value=nil, *extra_args)
          @observer_block.call(new_value, *extra_args)
        end
      end

      Registration = Struct.new(:observer, :observable, :args, keyword_init: true) do
        def deregister
          observer.unobserve(observable, *args)
        end
        alias unregister deregister
        alias unobserve deregister
      end

      class << self
        def proc(&observer_block)
          Proc.new(&observer_block)
        end
      end

      def registrations
        @registrations ||= Concurrent::Hash.new
      end

      def registration_for(observable, *args)
        args = compact_args(args)
        registrations[[observable.object_id, args]] ||= Registration.new(observer: self, observable: observable, args: args)
      end
      alias ensure_registration_for! registration_for

      # mapping of registrations to dependents
      # {[observable, property] => [[dependent, dependent_observable, dependent_property], ...]}
      def dependents
        @dependents ||= Concurrent::Hash.new
      end

      def dependents_for(registration)
        dependents[registration.object_id] ||= Concurrent::Set.new
      end

      # registers observer in an observable on args usually containing a property and options (optional)
      # observer maintains registration list to unregister later
      def observe(observable, *args)
        options = args.last.is_a?(Hash) ? args.last : {}
        return if observable.nil?
        return if options[:ignore_frozen] && observable.frozen?
        unless observable.is_a?(Observable)
          # TODO refactor code to be more smart/polymorphic/automated and honor open/closed principle (e.g. for SomeClass, search if there is ObservableSomeClass)
          if observable.is_a?(Array)
            observable.extend(ObservableArray)
          elsif observable.is_a?(Hash)
            observable.extend(ObservableHash)
          else
            observable.extend(ObservableModel)
          end
        end
        args = compact_args(args)
        observable.add_observer(self, *args)
        ensure_registration_for!(observable, *args)
      end
      alias register observe

      def unobserve(observable, *args)
        return unless observable.is_a?(Observable)
        args = compact_args(args)
        registration = registration_for(observable, *args)
        registrations.delete([observable.object_id, args])
        registration.tap do |registration|
          dependents_for(registration).each do |dependent|
            remove_dependent(registration => dependent)
            dependent.deregister if dependent != registration
          end
          observable.remove_observer(self, *args)
        end
      end
      alias unregister unobserve
      alias deregister unobserve

      def unobserve_dependents_with_observable(registration, dependent_observable)
        thedependents = dependents_for(registration).select do |thedependent|
          thedependent.observable == dependent_observable
        end
        thedependents.each(&:deregister)
      end
      alias unregister_dependents_with_observable unobserve_dependents_with_observable
      alias deregister_dependents_with_observable unobserve_dependents_with_observable

      # cleans up all registrations in observables
      def unobserve_all_observables
        registrations.values.dup.each do |registration|
          registration.deregister
          registrations.delete([registration.observable.object_id, registration.args])
        end
      end
      alias unregister_all_observables unobserve_all_observables
      alias deregister_all_observables unobserve_all_observables

      # add dependent observer to unregister when unregistering observer
      def add_dependent(parent_to_dependent_hash)
        registration = parent_to_dependent_hash.keys.first
        dependent = parent_to_dependent_hash.values.first
        dependents_for(registration) << dependent
      end

      def remove_dependent(parent_to_dependent_hash)
        registration = parent_to_dependent_hash.keys.first
        dependent = parent_to_dependent_hash.values.first
        dependents_for(registration).delete(dependent).tap do
          dependents.delete([registration.object_id]) if dependents_for(registration).empty?
        end
      end

      def call(new_value = nil, *extra_args)
        raise Error, 'Not implemented!'
      end
      
      def compact_args(args)
        args = args[0...-1] if args.last == {}
        args = args[0...-1] if args.last == []
        args.compact
      end
    end
  end
end

require 'glimmer/data_binding/observable_model'
require 'glimmer/data_binding/observable_array'
require 'glimmer/data_binding/observable_hash'
