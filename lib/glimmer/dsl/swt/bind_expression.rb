require 'glimmer/dsl/static_expression'
require 'glimmer/data_binding/model_binding'

module Glimmer
  module DSL
    module SWT
      # Responsible for setting up the return value of the bind keyword (command symbol)
      # as a ModelBinding. It is then used by another command handler like
      # DataBindingCommandHandler for text and selection properties on Text and Spinner
      # or TableItemsDataBindingCommandHandler for items in a Table
      class BindExpression < StaticExpression
        def can_interpret?(parent, keyword, *args, &block)
          (
            keyword == 'bind' and
              (
                (
                  (args.size == 2) and
                    textual?(args[1])
                ) ||
                  (
                    (args.size == 3) and
                      textual?(args[1]) and
                      (args[2].is_a?(Hash))
                  )
              )
          )
        end
  
        def interpret(parent, keyword, *args, &block)
          binding_options = args[2] || {}
          binding_options[:on_read] = binding_options.delete(:on_read) || binding_options.delete('on_read') || block
          DataBinding::ModelBinding.new(args[0], args[1].to_s, binding_options)
        end
      end
    end
  end
end
