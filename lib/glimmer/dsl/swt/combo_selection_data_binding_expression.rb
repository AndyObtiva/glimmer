require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/widget_binding'

module Glimmer
  module DSL
    module SWT
      class ComboSelectionDataBindingExpression < Expression
        include_package 'org.eclipse.swt.widgets'
  
        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'selection' and
            block.nil? and
            parent.respond_to?(:swt_widget) and
            parent.swt_widget.is_a?(Combo) and
            args.size == 1 and
            args[0].is_a?(DataBinding::ModelBinding) and
            args[0].evaluate_options_property.is_a?(Array)
        end
  
        def interpret(parent, keyword, *args, &block)
          model_binding = args[0]
  
          #TODO make this options observer dependent and all similar observers in widget specific data binding handlers
          # TODO consider delegating some of this work
          widget_binding = DataBinding::WidgetBinding.new(parent, 'items')
          widget_binding.call(model_binding.evaluate_options_property)
          model = model_binding.base_model
          widget_binding.observe(model, model_binding.options_property_name)
  
          widget_binding = DataBinding::WidgetBinding.new(parent, 'text')
          widget_binding.call(model_binding.evaluate_property)
          widget_binding.observe(model, model_binding.property_name_expression)
  
          parent.on_widget_selected do
            model_binding.call(widget_binding.evaluate_property)
          end
        end
      end
    end
  end
end
