require 'set'

# Mixin representing Observer trait from Observer Design Pattern
# Allows classes to include without interfering with their
# inheritance hierarchy.
module Observer
  def registrations
    @registrations ||= Set.new
  end

  def dependents
    @dependents ||= Set.new
  end

  def parents
    @dependents ||= Set.new
  end

  # helps observer remove itself from observables for cleaning purposes
  def register(observable, property = nil)
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
    self.registrations.delete([observable, property])
  end

  # cleans up all registrations in observables
  def unregister_all_observables
    self.registrations.each do |observable, property|
      unregister(observable, property)
    end
    unregister_all_dependent_observables
  end

  def unregister_all_dependent_observables
    self.dependents.each do |dependent|
      remove_dependent(dependent)
      dependent.unregister_all_observables if dependent.parents.empty?
    end
  end

  # add dependent observer to unregister when unregistering observer
  def add_dependent(observer)
    dependents << observer
    observer.parents << self
  end

  def remove_dependent(observer)
    dependents.delete(observer)
    observer.parents.delete(self)
  end

  def add_parent(observer)
    parents << observer
    observer.dependents << self
  end

  def remove_parent(observer)
    parents.delete(observer)
    observer.dependents.delete(self)
  end

  def update(changed_value)
    raise 'Not implemented!'
  end
end
