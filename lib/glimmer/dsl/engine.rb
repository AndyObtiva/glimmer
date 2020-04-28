require 'glimmer'
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
        attr_reader :dsl # active dsl

        def dsl=(dsl_name)
          @dsl = dsl_name&.to_sym
        end

        # Dynamic expression chains of responsibility indexed by dsl
        def dynamic_expression_chains_of_responsibility
          @dynamic_expression_chains_of_responsibility ||= {}
        end

        # Static expressions indexed by keyword and dsl
        def static_expressions
          @static_expressions ||= {}
        end

        # Sets an ordered array of DSL expressions to support
        #
        # Every expression has an underscored name corresponding to an upper
        # camelcase AbstractExpression subclass name in glimmer/dsl
        #
        # They are used in order following the Chain of Responsibility Design
        # Pattern when interpretting a DSL expression
        def add_dynamic_expressions(dsl_namespace, expression_names)
          dsl = dsl_namespace.name.split("::").last.downcase.to_sym
          dynamic_expression_chains_of_responsibility[dsl] = expression_names.reverse.reduce(nil) do |last_expresion_handler, expression_name|
            Glimmer.logger&.debug "Adding dynamic expression: #{dsl_namespace.name}::#{expression_class_name(expression_name)}"
            expression = expression_class(dsl_namespace, expression_name).new
            expression_handler = ExpressionHandler.new(expression)
            expression_handler.next = last_expresion_handler if last_expresion_handler
            expression_handler
          end
        end

        def add_static_expression(static_expression)
          Glimmer.logger&.debug "Adding static expression: #{static_expression.class.name}"
          keyword = static_expression.class.keyword
          static_expression_dsl = static_expression.class.dsl
          static_expressions[keyword] ||= {}
          static_expressions[keyword][static_expression_dsl] = lambda do |*args, &block|
            if !static_expression.can_interpret?(parent, keyword, *args, &block)
              raise Error, "Invalid use of Glimmer keyword #{keyword} with args #{args} under parent #{parent}"
            else
              Glimmer.logger&.debug "#{static_expression.class.name} will handle expression keyword #{keyword}"
              static_expression.interpret(parent, keyword, *args, &block).tap do |ui_object|
                Glimmer::DSL::Engine.add_content(ui_object, static_expression, &block) unless block.nil?
              end
            end
          end
          unless Glimmer.respond_to?(keyword)
            Glimmer.define_method(keyword) do |*args, &block|
              Glimmer::DSL::Engine.dsl = Glimmer::DSL::Engine.static_expressions[keyword].keys.first if Glimmer::DSL::Engine.dsl.nil?
              raise Glimmer::Error, "Unsupported keyword: #{keyword}" if Glimmer::DSL::Engine.dsl.nil?
              retrieved_static_expression = Glimmer::DSL::Engine.static_expressions[keyword][Glimmer::DSL::Engine.dsl]
              retrieved_static_expression.call(*args, &block)
            end
            
          end
        end

        def expression_class(dsl_namespace, expression_name)
          dsl_namespace.const_get(expression_class_name(expression_name).to_sym)
        end

        def expression_class_name(expression_name)
          "#{expression_name}_expression".camelcase(:upper)
        end

        # Interprets Glimmer DSL keyword, args, and block (e.g. shell(:no_resize) { ... })
        def interpret(keyword, *args, &block)
          keyword = keyword.to_s
          self.dsl =  dynamic_expression_chains_of_responsibility.keys.first if dsl.nil?
          expression = dynamic_expression_chains_of_responsibility[dsl].handle(parent, keyword, *args, &block)
          expression.interpret(parent, keyword, *args, &block).tap do |ui_object|
            add_content(ui_object, expression, &block)
          end
        end

        # Adds content block to parent UI object
        #
        # This allows evaluating parent UI object properties and children
        #
        # For example, a shell widget would get properties set and children added
        def add_content(parent, expression, &block)
          parent_stack.push(parent) if expression.is_a?(ParentExpression)
          expression.add_content(parent, &block) if block_given?
          parent_stack.pop if expression.is_a?(ParentExpression)
        end

        # Current parent while evaluating Glimmer DSL (nil if just started or done evaluatiing)
        #
        # Parents are maintained in a stack while evaluating Glimmer DSL
        # to ensure properly ordered interpretation of DSL syntax
        def parent
          parent_stack.last
        end

        def parent_stack
          @parent_stack ||= []
        end
      end
    end
  end
end
