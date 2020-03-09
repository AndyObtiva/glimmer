require 'set'

require_relative 'observer'
require_relative 'block_observer'

module ObservableModel
  class Updater
    include Observer
    def initialize(observable_model, property_name)
      @observable_model = observable_model
      @property_name = property_name
    end
    def update(changed_value=nil)
      @observable_model.notify_observers(@property_name)
    end
  end

  # Takes observer as an object or a block updater
  def add_observer(property_name, observer = nil, &updater)
    observer ||= BlockObserver.new(&updater)
    return observer if has_observer?(property_name, observer)
    property_observer_list(property_name) << observer
    add_property_writer_observers(property_name)
    observer.register(self, property_name)
    observer
  end

  def remove_observer(property_name, observer = nil)
    property_observer_list(property_name).delete(observer)
  end

  def has_observer?(property_name, observer)
    property_observer_list(property_name).include?(observer)
  end

  def property_observer_hash
    @property_observers = Hash.new unless @property_observers
    @property_observers
  end

  def property_observer_list(property_name)
    property_observer_hash[property_name.to_sym] = Set.new unless property_observer_hash[property_name.to_sym]
    property_observer_hash[property_name.to_sym]
  end

  def notify_observers(property_name)
    property_observer_list(property_name).each {|observer| observer.update(send(property_name))}
  end

  def add_property_writer_observers(property_name)
    property_writer_name = "#{property_name}="
    ensure_array_object_observer(property_name, send(property_name))
    begin
      method("__original_#{property_writer_name}")
    rescue
      instance_eval "alias __original_#{property_writer_name} #{property_writer_name}"
      instance_eval <<-end_eval, __FILE__, __LINE__
        def #{property_writer_name}(value)
          self.__original_#{property_writer_name}(value)
          notify_observers('#{property_name}')
          ensure_array_object_observer('#{property_name}', value)
        end
      end_eval
    end
  end

  def ensure_array_object_observer(property_name, object)
    return unless object.is_a?(Array)
    object.extend(ObservableArray) unless object.is_a?(ObservableArray)
    array_object_observer = array_object_observer_for(property_name)
    object.add_array_observer(array_object_observer)
    property_observer_list(property_name).each do |observer|
      observer.add_dependent(array_object_observer)
    end
  end

  def array_object_observer_for(property_name)
    @array_object_observers ||= {}
    unless @array_object_observers.has_key?(property_name)
      @array_object_observers[property_name] = ObservableModel::Updater.new(self, property_name)
    end
    @array_object_observers[property_name]
  end
end
