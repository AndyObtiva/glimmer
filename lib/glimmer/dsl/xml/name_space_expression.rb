require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/top_level_expression'
require 'glimmer/xml/node'
require 'glimmer/xml/depth_first_search_iterator'
require 'glimmer/xml/name_space_visitor'

module Glimmer
  module DSL
    module XML
      class NameSpaceExpression < StaticExpression
        include TopLevelExpression

        def can_interpret?(parent, keyword, *args, &block)
          (parent == nil or parent.is_a?(Glimmer::XML::Node)) and
          (keyword.to_s == "name_space")
          (args.size == 1) and
          (args[0].is_a?(Symbol)) and
          block
        end

        def interpret(parent, keyword, *args, &block)
          node = block.call
          unless node.is_a?(String)
            name_space_visitor = Glimmer::XML::NameSpaceVisitor.new(args[0].to_s)
            Glimmer::XML::DepthFirstSearchIterator.new(node, name_space_visitor).iterate
            def node.process_block(block)
              Glimmer.logger&.debug 'block'
              #NOOP
            end
          end
          parent.children << node if parent and !parent.children.include?(node)
          node
        end
      end
    end
  end
end
