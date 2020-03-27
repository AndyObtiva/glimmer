require_relative 'observable'
require_relative 'observer'

module Glimmer
  module SWT
    class WidgetBinding
      include Glimmer
      include Observable
      include Observer

      attr_reader :widget, :property
      def initialize(model, property, translator = nil)
        @widget = model
        @property = property
        @translator = translator || proc {|value| value}
        disposable_widget = @widget.is_a?(CustomWidget) ? @widget.non_custom_body_root : @widget
        add_contents(disposable_widget) { # TODO consider having custom widgets support on_widget_disposed event and any event on their body_root
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
        @widget.get_attribute(@property)
      end
    end
  end
end
