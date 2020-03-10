require 'set'

# Mixin representing Observer trait from Observer Design Pattern
# Allows classes to include without interfering with their
# inheritance hierarchy.
module Observer
  def registrations
    @registrations ||= Set.new
  end

  def registrations_for(observable, property = nil)
    registrations.select {|o, p| o == observable && p == property}
  end

  # mapping of registrations to dependents
  # {[observable, property] => [[dependent, dependent_observable, dependent_property], ...]}
  def dependents
    @dependents ||= Hash.new
  end

  def dependents_for(registration)
    dependents[registration] ||= Set.new
  end

  def parents
    @parents ||= Hash.new
  end

  def parents_for(registration)
    parents[registration] ||= Set.new
  end

  # helps observer remove itself from observables for cleaning purposes
  def register(observable, property = nil)
    #TODO consider performing add observer here to avoid having to extend model as observable (simplify)
    [observable, property].tap do |registration|
      self.registrations << registration
    end
  end

  def unregister(observable, property = nil)
    if observable.is_a?(ObservableArray)
      observable.remove_array_observer(self)
    elsif observable.is_a?(ObservableModel)
      observable.remove_observer(property, self)
    else
      observable.remove_observer(self)
    end
    registration = [observable, property]
    dependents_for(registration).each do |dependent|
      dependent_observer, dependent_observable, dependent_property = dependent
      dependent_observer.unregister(dependent_observable, dependent_property)
      remove_dependent(registration => dependent)
    end
    registrations.delete(registration)
  end

  def unregister_dependents_with_observable(registration, dependent_observable)
    thedependents = dependents_for(registration).select do |d_observer, d_observable, d_property|
      d_observable == dependent_observable
    end
    thedependents.each do |d_observer, d_observable, d_property|
      d_observer.unregister(d_observable, d_property)
    end
  end

  # cleans up all registrations in observables
  def unregister_all_observables
    registrations.each do |observable, property|
      unregister(observable, property)
    end
  end

  # add dependent observer to unregister when unregistering observer
  def add_dependent(parent_to_dependent_hash)
    observable, property = registration = parent_to_dependent_hash.keys.first
    dependent_observer, dependent_observable, dependent_property = dependent = parent_to_dependent_hash.values.first
    dependents_for(registration) << dependent
    dependent_observer.parents_for([dependent_observable, dependent_property]) << ([self] + registration)
  end

  def remove_dependent(parent_to_dependent_hash)
    observable, property = registration = parent_to_dependent_hash.keys.first
    dependent_observer, dependent_observable, dependent_property = dependent = parent_to_dependent_hash.values.first
    dependents_for(registration).delete(dependent)
    dependent_observer.parents_for([dependent_observable, dependent_property]).delete([self] + registration)
  end

  def update(changed_value)
    raise 'Not implemented!'
  end
end
