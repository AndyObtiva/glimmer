require File.dirname(__FILE__) + "/observer"

class ModelBinding
  include Observer

  attr_reader :property_type, :binding_options
  @@property_type_converters = {
    :undefined => lambda { |value| value },
    :fixnum => lambda { |value| value.to_i },
    :array => lambda { |value| value.to_a }
  }
  def initialize(base_model, property_name_expression, property_type = :undefined, binding_options = nil)
    property_type = :undefined if property_type.nil?
    @base_model = base_model
    @property_name_expression = property_name_expression
    @property_type = property_type
    @binding_options = binding_options || {}
  end
  def model
    nested_property? ? nested_model : base_model
  end
  # e.g. person.address.state returns [person, person.address]
  def nested_models
    @nested_models = [base_model]
    model_property_names.reduce(base_model) do |reduced_model, nested_model_property_name|
      if nested_model_property_name.start_with?('[')
        property_method = '[]'
        property_argument = nested_model_property_name[1...-1]
        property_argument = property_argument.to_i if property_argument.match(/\d+/)
        new_reduced_model = reduced_model.send(property_method, property_argument)
      else
        new_reduced_model = reduced_model.send(nested_model_property_name)
      end
      @nested_models << new_reduced_model
      new_reduced_model
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
    property_name_expression.include?(".")
  end
  def property_name_expression
    @property_name_expression
  end
  def nested_property_observers_for(observer)
    @nested_property_observers_collection ||= {}
    unless @nested_property_observers_collection.has_key?(observer)
      @nested_property_observers_collection[observer] = nested_property_names.reduce({}) do |output, property_name|
        output.merge(
          property_name => BlockObserver.new do |changed_value|
            # Ensure reattaching observers when a higher level nested property is updated (e.g. person.address changes reattaches person.address.street observer)
            add_observer(observer)
            observer.update(evaluate_property)
          end
        )
      end
    end
    @nested_property_observers_collection[observer]
  end
  def add_observer(observer)
    if nested_property?
      nested_property_observers = nested_property_observers_for(observer)
      nested_models.zip(nested_property_names).each do |model, property_name|
        if property_name.start_with?('[')
          model.extend ObservableArray unless model.is_a?(ObservableArray)
          model.add_array_observer(nested_property_observers[property_name]) unless model.has_array_observer?(nested_property_observers[property_name])
        else
          model.extend ObservableModel unless model.is_a?(ObservableModel)
          model.add_observer(property_name, nested_property_observers[property_name]) unless model.has_observer?(property_name, nested_property_observers[property_name])
        end
      end
    else
      model.extend ObservableModel unless model.is_a?(ObservableModel)
      model.add_observer(property_name, observer)
    end
  end
  def update(value)
    #TODO support for nested property
    converted_value = @@property_type_converters[@property_type].call(value)
    model.send(property_name + "=", converted_value) unless evaluate_property == converted_value
  end
  def evaluate_property
    #TODO support for nested indexed property
    model.send(property_name)
  end
  def evaluate_options_property
    #TODO support for nested property
    #TODO support for nested indexed property
    model.send(property_name + "_options")
  end
  def options_property_name
    self.property_name + "_options"
  end
end
