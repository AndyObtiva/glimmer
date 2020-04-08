module Glimmer
  module DSL
    # Represents a Glimmer DSL expression (e.g. label(:center) { ... })
    #
    # An expression object can interpret a keyword, args, and a block into a UI object
    class Expression
      def can_interpret?(parent, keyword, *args, &block)
        raise "must be implemented by a class"
      end

      def interpret(parent, keyword, *args, &block)
        raise "must be implemented by a class"
      end

      # Expressions that receive a content block must implement this method
      def add_content(parent, &block)
        # No Op by default
      end

      def widget?(parent)
        parent.is_a?(GWidget) || parent.is_a?(CustomWidget)
      end

      def textual?(object)
        object.is_a?(Symbol) || object.is_a?(String)
      end
    end
  end
end
