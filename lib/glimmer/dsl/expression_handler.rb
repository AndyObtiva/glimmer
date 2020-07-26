require 'glimmer/invalid_keyword_error'

module Glimmer
  module DSL
    # Expression handler for a Glimmer DSL specific expression
    #
    # Follows the Chain of Responsibility Design Pattern
    #
    # Handlers are configured in Glimmer::DSL in the right order
    # to attempt handling Glimmer DSL interpretation calls
    #
    # Each handler knows the next handler in the chain of responsibility.
    #
    # If it handles successfully, it returns. Otherwise, it forwards to the next
    # handler in the chain of responsibility
    class ExpressionHandler
      def initialize(expression)
        @expression = expression
      end

      # Handles interpretation of Glimmer DSL expression if expression supports it
      # If it succeeds, it returns the correct Glimmer DSL expression object
      # Otherwise, it forwards to the next handler configured via `#next=` method
      # If there is no handler next, then it raises an error
      def handle(parent, keyword, *args, &block)
        Glimmer::Config.logger.info {"Attempting to handle #{keyword} with #{@expression.class.name.split(":").last}"}
        if @expression.can_interpret?(parent, keyword, *args, &block)
          Glimmer::Config.logger.info {"#{@expression.class.name} will handle expression keyword #{keyword}"}
          return @expression
        elsif @next_expression_handler
          return @next_expression_handler.handle(parent, keyword, *args, &block)
        else
          # TODO see if we need a better response here (e.g. dev mode error raising vs production mode silent failure)
          message = "Glimmer keyword #{keyword} with args #{args} cannot be handled"
          message += " inside parent #{parent}" if parent
          message += "! Check the validity of the code."
          raise InvalidKeywordError, message
        end
      end

      # Sets the next handler in the expression handler chain of responsibility
      def next=(next_expression_handler)
        @next_expression_handler = next_expression_handler
      end
    end
  end
end
