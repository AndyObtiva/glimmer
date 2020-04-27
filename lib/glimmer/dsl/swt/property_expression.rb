require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    class PropertyExpression < Expression
      def can_interpret?(parent, keyword, *args, &block)
        block.nil? and
          args.size > 0 and
          parent.respond_to?(:set_attribute) and
          parent.respond_to?(:has_attribute?) and
          parent.has_attribute?(keyword, *args)
      end

      def interpret(parent, keyword, *args, &block)
        parent.set_attribute(keyword, *args)
        nil
      end
    end
  end
end
