require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'

module Glimmer
  module DSL
    # Responsible for setting up the return value of the bind keyword (command symbol)
    # as a ModelBinding. It is then used by another command handler like
    # DataBindingCommandHandler for text and selection properties on Text and Spinner
    # or TableItemsDataBindingCommandHandler for items in a Table
    class BindExpression < Expression
      def can_interpret?(parent, keyword, *args, &block)
        (
          keyword == 'bind' &&
            block == nil &&
            widget?(parent) &&
            (
              (
                (args.size == 2) &&
                  textual?(args[1])
              ) ||
                (
                  (args.size == 3) &&
                    textual?(args[1]) &&
                    (textual?(args[2]) || args[2].is_a?(Hash))
                ) ||
                (
                  (args.size == 4) &&
                    textual?(args[1]) &&
                    textual?(args[2]) &&
                    (args[3].is_a?(Hash))
                )
            )
        )
      end

      def interpret(parent, keyword, *args, &block)
        property_type = args[2] if (args.size == 3) && !args[2].is_a?(Hash)
        binding_options = args[2] if args[2].is_a?(Hash)
        binding_options = args[3] if args[3].is_a?(Hash)
        DataBinding::ModelBinding.new(args[0], args[1].to_s, property_type, binding_options)
      end
    end
  end
end
