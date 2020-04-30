require 'glimmer/dsl/xml/node_parent_expression'
require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/top_level_expression'
require 'glimmer/xml/node'

module Glimmer
  module DSL
    module XML
      class TagExpression < StaticExpression
        include TopLevelExpression
        include NodeParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          (parent == nil or parent.is_a?(Glimmer::XML::Node)) and
          (keyword.to_s == "tag") and
          ((args.size == 1) and ((args[0].is_a?(Hash)) or (args[0].is_a?(Hash)))) and
          args[0].include?(:_name)
        end

        def interpret(parent, keyword, *args, &block)
          attributes = nil
          attributes = args[0] if (args.size == 1)
          tag_name = attributes[:_name]
          attributes.delete(:_name)
          Glimmer::XML::Node.new(parent, tag_name, attributes, &block)
        end
      end
    end
  end
end
