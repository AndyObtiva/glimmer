require 'facets/string/camelcase'

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
      MESSAGE_NO_DSLS = "Glimmer has no DSLs configured. Add glimmer-dsl-swt gem or visit https://github.com/AndyObtiva/glimmer#multi-dsl-support for more details.\n"
      
      class << self
        def dsl=(dsl_name)
          dsl_name = dsl_name&.to_sym
          if dsl_name
            dsl_stack.push(dsl_name)
          else
            dsl_stack.clear
          end
        end
        
        def dsl
          dsl_stack.last
        end

        def dsls
          static_expressions.values.map(&:keys).flatten.uniq
        end

        def disable_dsl(dsl_name)
          dsl_name = dsl_name.to_sym
          disabled_dsls << dsl_name
        end

        def enable_dsl(dsl_name)
          dsl_name = dsl_name.to_sym
          disabled_dsls.delete(dsl_name)
        end

        def disabled_dsls
          @disabled_dsls ||= []
        end

        def enabled_dsls=(dsl_names)
          dsls.each {|dsl_name| disable_dsl(dsl_name)}
          dsl_names.each {|dsl_name| enable_dsl(dsl_name)}
        end
    
        # Resets Glimmer's engine activity and configuration. Useful in rspec before or after blocks in tests.
        def reset
          parent_stacks.values.each do |a_parent_stack|
            a_parent_stack.clear
          end
          dsl_stack.clear
          disabled_dsls.clear
        end
        
        def no_dsls?
          static_expressions.empty? && dynamic_expression_chains_of_responsibility.empty?
        end

        # Dynamic expression chains of responsibility indexed by dsl
        def dynamic_expression_chains_of_responsibility
          @dynamic_expression_chains_of_responsibility ||= {}
        end

        # Static expressions indexed by keyword and dsl
        def static_expressions
          @static_expressions ||= {}
        end        

        # Sets dynamic expression chains of responsibility. Useful for internal testing
        def dynamic_expression_chains_of_responsibility=(chains)
          @dynamic_expression_chains_of_responsibility = chains
        end

        # Sets static expressions. Useful for internal testing
        def static_expressions=(expressions)
          @static_expressions = expressions
        end

        # Sets an ordered array of DSL expressions to support
        #
        # Every expression has an underscored name corresponding to an upper
        # camelcase AbstractExpression subclass name in glimmer/dsl
        #
        # They are used in order following the Chain of Responsibility Design
        # Pattern when interpretting a DSL expression
        def add_dynamic_expressions(dsl_namespace, *expression_names)
          expression_names = expression_names.flatten
          dsl = dsl_namespace.name.split("::").last.downcase.to_sym          
          dynamic_expression_chains_of_responsibility[dsl] = expression_names.reverse.map do |expression_name|
            expression_class(dsl_namespace, expression_name).new
          end.reduce(nil) do |last_expresion_handler, expression|
            Glimmer::Config.logger.info {"Adding dynamic expression: #{expression.class.name}"}
            expression_handler = ExpressionHandler.new(expression)
            expression_handler.next = last_expresion_handler if last_expresion_handler
            expression_handler
          end                   
        end

        def add_static_expression(static_expression)
          Glimmer::Config.logger.info {"Adding static expression: #{static_expression.class.name}"}
          keyword = static_expression.class.keyword
          static_expression_dsl = static_expression.class.dsl
          static_expressions[keyword] ||= {}
          static_expressions[keyword][static_expression_dsl] = static_expression
          Glimmer.send(:define_method, keyword) do |*args, &block|
            if Glimmer::DSL::Engine.no_dsls?
              puts Glimmer::DSL::Engine::MESSAGE_NO_DSLS
            else
              retrieved_static_expression = Glimmer::DSL::Engine.static_expressions[keyword][Glimmer::DSL::Engine.dsl]
              static_expression_dsl = (Glimmer::DSL::Engine.static_expressions[keyword].keys - Glimmer::DSL::Engine.disabled_dsls).first if retrieved_static_expression.nil?
              interpretation = nil
              if retrieved_static_expression.nil? && Glimmer::DSL::Engine.dsl && (static_expression_dsl.nil? || !Glimmer::DSL::Engine.static_expressions[keyword][static_expression_dsl].is_a?(TopLevelExpression))
                begin
                  interpretation = Glimmer::DSL::Engine.interpret(keyword, *args, &block)
                rescue => e
                  raise e if static_expression_dsl.nil? || !Glimmer::DSL::Engine.static_expressions[keyword][static_expression_dsl].is_a?(TopLevelExpression)
                end
              end
              if interpretation
                interpretation
              else              
                raise Glimmer::Error, "Unsupported keyword: #{keyword}" unless static_expression_dsl || retrieved_static_expression
                Glimmer::DSL::Engine.dsl_stack.push(static_expression_dsl || Glimmer::DSL::Engine.dsl)
                static_expression = Glimmer::DSL::Engine.static_expressions[keyword][Glimmer::DSL::Engine.dsl]
                if !static_expression.can_interpret?(Glimmer::DSL::Engine.parent, keyword, *args, &block)
                  raise Error, "Invalid use of Glimmer keyword #{keyword} with args #{args} under parent #{Glimmer::DSL::Engine.parent}"
                else
                  Glimmer::Config.logger.info {"#{static_expression.class.name} will handle expression keyword #{keyword}"}
                  static_expression.interpret(Glimmer::DSL::Engine.parent, keyword, *args, &block).tap do |ui_object|
                    Glimmer::DSL::Engine.add_content(ui_object, static_expression, &block) unless block.nil?
                    Glimmer::DSL::Engine.dsl_stack.pop
                  end
                end
              end
            end              
          end
        end

        def expression_class(dsl_namespace, expression_name)
          dsl_namespace.const_get(expression_class_name(expression_name).to_sym)
        end

        def expression_class_name(expression_name)
          "#{expression_name}_expression".camelcase(:upper)
        end

        # Interprets Glimmer dynamic DSL expression consisting of keyword, args, and block (e.g. shell(:no_resize) { ... })
        def interpret(keyword, *args, &block)
          if no_dsls?
            puts MESSAGE_NO_DSLS
            return
          end
          keyword = keyword.to_s
          dynamic_expression_dsl = (dynamic_expression_chains_of_responsibility.keys - disabled_dsls).first if dsl.nil?
          dsl_stack.push(dynamic_expression_dsl || dsl)
          expression = dynamic_expression_chains_of_responsibility[dsl].handle(parent, keyword, *args, &block)
          expression.interpret(parent, keyword, *args, &block).tap do |ui_object|            
            add_content(ui_object, expression, &block)
            dsl_stack.pop
          end
        end

        # Adds content block to parent UI object
        #
        # This allows evaluating parent UI object properties and children
        #
        # For example, a shell widget would get properties set and children added
        def add_content(parent, expression, &block)
          if block_given? && expression.is_a?(ParentExpression)
            dsl_stack.push(expression.class.dsl)
            parent_stack.push(parent) 
            begin
              expression.add_content(parent, &block)
            ensure
              parent_stack.pop
              dsl_stack.pop
            end
          end
        end

        # Current parent while evaluating Glimmer DSL (nil if just started or done evaluatiing)
        #
        # Parents are maintained in a stack while evaluating Glimmer DSL
        # to ensure properly ordered interpretation of DSL syntax
        def parent
          parent_stack.last
        end

        def parent_stack
          parent_stacks[dsl] ||= []
        end

        def parent_stacks
          @parent_stacks ||= {}
        end

        # Enables multiple DSLs to play well with each other when mixing together
        def dsl_stack
          @dsl_stack ||= []
        end
      end
    end
  end
end
