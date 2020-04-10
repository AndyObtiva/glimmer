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
        def call(new_value=nil)
          @observer_block.call(new_value)
        end
      end

      class Registration < Struct.new(:observer, :observable, :property, keyword_init: true)
        def unregister
          observer.unobserve(observable, property)
        end
        alias unobserve unregister
      end

      class << self
        def proc(&observer_block)
          Proc.new(&observer_block)
        end
      end

      def registrations
        @registrations ||= Set.new
      end

      def registration_for(observable, property = nil)
        Registration.new(observer: self, observable: observable, property: property)
      end

      # mapping of registrations to dependents
      # {[observable, property] => [[dependent, dependent_observable, dependent_property], ...]}
      def dependents
        @dependents ||= Hash.new
      end

      def dependents_for(registration)
        dependents[registration] ||= Set.new
      end

      # registers observer in an observable on a property (optional)
      # observer maintains registration list to unregister later
      def register(observable, property = nil)
        unless observable.is_a?(Observable)
          # TODO refactor code to be more smart/polymorphic/automated and honor open/closed principle
          if observable.is_a?(Array)
            observable.extend(ObservableArray)
          else
            observable.extend(ObservableModel)
          end
        end
        observable.add_observer(*[self, property].compact)
        registration_for(observable, property).tap do |registration|
          self.registrations << registration
        end
      end
      alias observe register

      def unregister(observable, property = nil)
        # TODO optimize performance in the future via indexing and/or making a registration official object/class
        observable.remove_observer(*[self, property].compact)
        registration = registration_for(observable, property)
        dependents_for(registration).each do |dependent|
          dependent.unregister
          remove_dependent(registration => dependent)
        end
        registrations.delete(registration)
      end
      alias unobserve unregister

      def unregister_dependents_with_observable(registration, dependent_observable)
        thedependents = dependents_for(registration).select do |thedependent|
          thedependent.observable == dependent_observable
        end
        thedependents.each do |thedependent|
          thedependent.unregister
        end
      end

      # cleans up all registrations in observables
      def unregister_all_observables
        registrations.each do |registration|
          registration.unregister
        end
      end
      alias unobserve_all_observables unregister_all_observables

      # add dependent observer to unregister when unregistering observer
      def add_dependent(parent_to_dependent_hash)
        registration = parent_to_dependent_hash.keys.first
        dependent = parent_to_dependent_hash.values.first
        dependents_for(registration) << dependent
      end

      def remove_dependent(parent_to_dependent_hash)
        registration = parent_to_dependent_hash.keys.first
        dependent = parent_to_dependent_hash.values.first
        dependents_for(registration).delete(dependent)
      end

      def call(new_value)
        raise Error, 'Not implemented!'
      end
    end
  end
end
