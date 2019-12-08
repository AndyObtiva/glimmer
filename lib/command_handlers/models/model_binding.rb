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
  def nested_model
    property_name_expression.split(".")[0...-1].reduce(base_model) do |reduced_model, nested_model_property_name|
      reduced_model.send(nested_model_property_name)
    end
  end
  def base_model
    @base_model
  end
  def property_name
    nested_property? ? nested_property_name : property_name_expression
  end
  def nested_property_name
    property_name_expression.split(".")[-1].to_sym
  end
  def nested_property?
    property_name_expression.include?(".")
  end
  def property_name_expression
    @property_name_expression
  end
  def update(value)
    converted_value = @@property_type_converters[@property_type].call(value)
    model.send(property_name + "=", converted_value) unless evaluate_property == converted_value
  end
  def evaluate_property
    model.send(property_name)
  end
  def evaluate_options_property
    model.send(property_name + "_options")
  end
  def options_property_name
    self.property_name + "_options"
  end
end
