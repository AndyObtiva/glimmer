require 'glimmer/error'

module Glimmer
  module DSL
    # Mixin that represents expressions that always have a content block
    module ParentExpression
      def add_content(parent, &block)
        block.call(parent)
      end
    end
  end
end
