require 'glimmer/swt/widget_proxy'
require 'glimmer/ui/custom_widget'

module Glimmer
  module DSL
    # Represents a StaticExpression for expressions where
    # the keyword does not vary dynamically. These static keywords are then
    # predefined as methods in Glimmer instead of needing method_missing
    #
    # StaticExpression subclasses may optionally implement `#can_interpret?`
    # (not needed if it only checks for keyword)
    #
    # StaticExpression subclasses must define `#interpret`.
    class StaticExpression < Expression
      def self.inherited(base)
        keyword = base.name.split(/::/).last.sub(/Expression$/, '').underscore
        static_expression = base.new
        Glimmer.define_method(keyword) do |*args, &block|
          parent = Glimmer::DSL::Engine.current_parent
          if !static_expression.can_interpret?(parent, keyword, *args, &block)
            raise "Invalid use of Glimmer keyword #{keyword} with args #{args.inspect} under parent #{parent.inspect}"
          else
            static_expression.interpret(parent, keyword, *args, &block).tap do |ui_object|
              Glimmer::DSL::Engine.add_content(ui_object, static_expression, &block) unless block.nil?
            end
          end
        end
      end

      # Subclasses may optionally implement
      def can_interpret?(parent, keyword, *args, &block)
        true
      end
    end
  end
end
