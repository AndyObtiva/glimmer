Dir['glimmer/dsl/**/*_expression.rb'].each {|f| require f}
require 'glimmer/dsl/expression_handler'

module Glimmer
  module DSL
    # Glimmer DSL Engine
    #
    # Follows Interpreter and Chain of Responsibility Design Patterns
    #
    # When DSL engine interprets an expression, it attempts to handle
    # with ordered expression array specified via `.expressions=` method.
    #
    # TODO support auto-loading static_expressions in the future for expressions where
    # the keyword does not vary dynamically. These static keywords are then
    # predefined as methods in Glimmer instead of needing method_missing
    class Engine
      class << self
        # Sets an ordered array of DSL expressions to support
        #
        # Every expression has an underscored name corresponding to an upper
        # camelcase AbstractExpression subclass name in glimmer/dsl
        #
        # They are used in order following the Chain of Responsibility Design
        # Pattern when interpretting a DSL expression
        #
        # TODO rename to dynamic_expressions in the future when supporting static expressions
        def expressions=(expression_names)
          @expression_chain_of_responsibility = expression_names.reverse.reduce(nil) do |last_expresion_handler, expression_name|
            Glimmer.logger.debug "Loading #{expression_class_name(expression_name)}..."
            expression = expression_class(expression_name).new
            expression_handler = ExpressionHandler.new(expression)
            expression_handler.next = last_expresion_handler if last_expresion_handler
            expression_handler
          end
        end

        def expression_class(expression_name)
          const_get(expression_class_name(expression_name).to_sym)
        end

        def expression_class_name(expression_name)
          "#{expression_name}_expression".camelcase(:upper)
        end

        # Interprets Glimmer DSL keyword, args, and block (e.g. shell(:no_resize) { ... })
        def interpret(keyword, *args, &block)
          keyword = keyword.to_s
          expression = @expression_chain_of_responsibility.handle(current_parent, keyword, *args, &block)
          expression.interpret(current_parent, keyword, *args, &block).tap do |ui_object|
            add_content(ui_object, &block)
          end
        end

        # Adds content block to parent UI object
        #
        # This allows evaluating parent UI object properties and children
        #
        # For example, a shell widget would get properties set and children added
        def add_content(parent, &block)
          parent_stack.push(parent)
          expression.add_content(&block)
          parent_stack.pop
        end

        # Current parent while evaluating Glimmer DSL (nil if just started or done evaluatiing)
        #
        # Parents are maintained in a stack while evaluating Glimmer DSL
        # to ensure properly ordered interpretation of DSL syntax
        def current_parent
          parent_stack.last
        end

        private

        def parent_stack
          @parent_stack ||= []
        end
      end
    end
  end
end
