require_relative 'observable'
require_relative 'observer'

class WidgetBinding
  include Glimmer
  include Observable
  include Observer

  attr_reader :widget, :property
  def initialize(model, property, translator = nil)
    @widget = model
    @property = property
    @translator = translator || proc {|value| value}
    add_contents(@widget) {
      on_widget_disposed { |dispose_event|
        unregister_all_observables
      }
    }
  end
  def call(value)
    converted_value = translated_value = @translator.call(value)
    @widget.set_attribute(@property, converted_value) unless evaluate_property == converted_value
  end
  def evaluate_property
    @widget.widget.send(@property)
  end
end
