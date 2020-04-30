require 'glimmer/dsl/xml/node_parent_expression'
require 'glimmer/dsl/expression'
require 'glimmer/xml/node'

module Glimmer
  module DSL
    module XML
      class XmlExpression < Expression
        include NodeParentExpression

        SUPPORTED_ARG_TYPES = [String, Symbol, Hash]

        def can_interpret?(parent, keyword, *args, &block)
          hash_arg = args.detect {|arg| arg.is_a?(Hash)}
          parent.is_a?(Glimmer::XML::Node) and
            ((SUPPORTED_ARG_TYPES & args.map(&:class).uniq) == args.map(&:class).uniq) and
            args.map(&:class).count(Hash) <= 1 and
            ((args.index(hash_arg) == args.size - 1) or args.index(hash_arg).nil?)
        end

        def interpret(parent, keyword, *args, &block)
          Glimmer::XML::Node.new(parent, keyword.to_s, args, &block)
        end
      end
    end
  end
end
