require 'glimmer/error'

module Glimmer
  module DSL
    # Represents a Glimmer DSL expression (e.g. label(:center) { ... })
    #
    # An expression object can interpret a keyword, args, and a block into a UI object
    #
    # Expressions subclasses follow the convention of using `and` and `or`
    # english versino of Ruby's boolean operations. This allows easy DSL-like
    # readability of the rules, and easy tagging with pd when troubleshooting.
    class Expression
      # Checks if it can interpret parameters (subclass must override)
      def can_interpret?(parent, keyword, *args, &block)
        raise Error, "must be implemented by a class"
      end

      # Interprets parameters (subclass must override)
      def interpret(parent, keyword, *args, &block)
        raise Error, "must be implemented by a class"
      end

      # Adds block content to specified parent UI object (Optional)
      #
      # Only expressions that receive a content block should implement
      def add_content(parent, &block)
        # No Op by default
      end

      # Checks if parent object is a widget
      def widget?(parent)
        parent.is_a?(SWT::WidgetProxy) or parent.is_a?(UI::CustomWidget)
      end

      # Checks if object is a Symbol or a String
      def textual?(object)
        object.is_a?(Symbol) or object.is_a?(String)
      end
    end
  end
end

require 'glimmer/swt/widget_proxy'
require 'glimmer/ui/custom_widget'
