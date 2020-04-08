require 'glimmer/dsl/expression'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/model_binding'

module Glimmer
  module DSL
    class ObserveExpression < Expression
      REGEX_NESTED_OR_INDEXED_PROPERTY = /([^\[]+)(\[[^\]]+\])?/

      def can_interpret?(parent, keyword, *args, &block)
        keyword == 'observe' &&
          !block.nil? &&
          (args.size == 2) &&
          textual?(args[1])
      end

      def interpret(parent, keyword, *args, &block)
        observer = DataBinding::Observer.proc(&block)
        if args[1].to_s.match(REGEX_NESTED_OR_INDEXED_PROPERTY)
          observer.observe(DataBinding::ModelBinding.new(args[0], args[1]))
        else
          observer.observe(args[0], args[1])
        end
      end
    end
  end
end
