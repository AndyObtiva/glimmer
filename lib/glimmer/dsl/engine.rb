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
    class Engine
      class << self
        # Sets an ordered array of DSL expressions to support
        #
        # Every expression has an underscored name corresponding to an upper
        # camelcase AbstractExpression subclass name in glimmer/dsl
        #
        # They are used in order following the Chain of Responsibility Design
        # Pattern when interpretting a DSL expression
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

        def interpret(keyword, *args, &block)
          keyword = keyword.to_s
          expression = @expression_chain_of_responsibility.handle(current_parent, keyword, *args, &block)
          expression.interpret(current_parent, keyword, *args, &block).tap do |ui_object|
            add_content(ui_object, &block)
          end
        end

        def add_content(parent, &block)
          parent_stack.push(parent)
          expression.add_content(&block)
          parent_stack.pop
        end

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
