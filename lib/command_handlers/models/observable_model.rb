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
    unless has_observer?(property_name, observer)
      property_observer_list(property_name) << observer
      add_property_writer_observers(property_name)
      observer.register(self, property_name)
    end
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
    property_value = self.send(property_name)
    if (property_value.is_a?(Array) and
        !property_value.is_a?(ObservableArray))
      property_value.extend(ObservableArray)
      property_value.add_observer([], ObservableModel::Updater.new(self, property_name))
    end
    begin
      method("__original_#{property_writer_name}")
    rescue
      self.instance_eval "alias __original_#{property_writer_name} #{property_writer_name}"
      self.instance_eval <<-end_eval, __FILE__, __LINE__
        def #{property_writer_name}(value)
          self.__original_#{property_writer_name}(value)
          notify_observers('#{property_name}')
          if (value.is_a?(Array) and !value.is_a?(ObservableArray))
            value.extend(ObservableArray)
            value.add_array_observer(ObservableModel::Updater.new(self, '#{property_name}'))
          end
        end
      end_eval
    end
  end
end
