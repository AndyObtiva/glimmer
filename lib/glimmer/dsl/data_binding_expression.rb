require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/widget_binding'

module Glimmer
  module DSL
    # Responsible for wiring two-way data-binding for text and selection properties
    # on Text, Button, and Spinner widgets.
    # Does so by using the output of the bind(model, property) command in the form
    # of a ModelBinding, which is then connected to an anonymous widget observer
    # (aka widget_data_binder as per widget_data_binders array)
    #
    # Depends on BindCommandHandler
    class DataBindingExpression < Expression
      def can_interpret?(parent, keyword, *args, &block)
        args.size == 1 &&
        args[0].is_a?(DataBinding::ModelBinding) &&
        widget?(parent)
      end

      def interpret(parent, keyword, *args, &block)
        model_binding = args[0]
        widget_binding_parameters = [parent, keyword]
        widget_binding = DataBinding::WidgetBinding.new(*widget_binding_parameters)
        widget_binding.call(model_binding.evaluate_property)
        #TODO make this options observer dependent and all similar observers in widget specific data binding handlers
        widget_binding.observe(model_binding)
        # TODO simplify this logic and put it where it belongs
        parent.add_observer(model_binding, keyword)
      end
    end
  end
end
