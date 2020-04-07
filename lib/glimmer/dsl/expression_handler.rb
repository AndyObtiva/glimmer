module Glimmer
  module DSL
    class ExpressionHandler
      def initialize(expression)
        @expression = expression
      end

      def next=(next_expression_handler)
        @next_expression_handler = next_expression_handler
      end

      def handle(parent, keyword, *args, &block)
        if @expression.can_interpret?(parent, keyword, *args, &block)
          Glimmer.logger.debug "#{@expression.class.name} will handle expression keyword #{keyword} with arguments #{args}"
          return @expression
        elsif @next_expression_handler
          return @next_expression_handler.handle(parent, keyword, *args, &block)
        else
          # TODO see if we need a better response here (e.g. dev mode error raising vs production mode silent failure)
          message = "Glimmer keyword #{keyword} with args #{args} cannot be handled"
          message += " inside parent #{parent.inspect}" if parent
          message += "! Check the validity of the code."
          # Glimmer.logger.error message
          raise message
        end
      end
    end
  end
end
