class WidgetObserver
  attr_reader :widget, :property
  @@property_type_converters = {
    :text => Proc.new { |value| value.to_s },
    :items => Proc.new { |value| value.to_java :string}
  }
  def initialize(model, property, translator = nil)
    @widget = model
    @property = property
    @translator = translator || proc {|value| value}
  end
  def update(value)
    converted_value = translated_value = @translator.call(value)
    converter = @@property_type_converters[@property.to_sym]
    converted_value = converter.call(translated_value) if converter
    @widget.widget.send("set#{@property.camelcase(:upper)}", converted_value) unless evaluate_property == converted_value
  end
  def evaluate_property
    @widget.widget.send(@property)
  end
end
