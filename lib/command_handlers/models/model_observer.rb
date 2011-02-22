class ModelObserver
  attr_reader :model, :property_name, :property_type
  @@property_type_converters = {
    :undefined => lambda { |value| value }, 
    :fixnum => lambda { |value| value.to_i },
    :array => lambda { |value| value.to_a }
  }
  def initialize(model, property_name, property_type = :undefined)
    property_type = :undefined if property_type.nil?
    @model = model
    @property_name = property_name
    @property_type = property_type
  end
  def update(value)
    converted_value = @@property_type_converters[@property_type].call(value)
    @model.send(@property_name + "=", converted_value) unless evaluate_property == converted_value
  end
  def evaluate_property
    @model.send(@property_name)
  end
  def evaluate_options_property
    @model.send(@property_name + "_options")
  end
  def options_property_name
    self.property_name + "_options"    
  end
end
  
