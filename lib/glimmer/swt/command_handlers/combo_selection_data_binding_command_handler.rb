require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_widget"
require File.dirname(__FILE__) + "/../custom_widget"

module Glimmer
  module SWT
    module CommandHandlers
      class ComboSelectionDataBindingCommandHandler
        include CommandHandler

        include_package 'org.eclipse.swt.widgets'

        def can_handle?(parent, command_symbol, *args, &block)
          command_symbol.to_s == "selection" &&
            block == nil &&
            (parent.is_a?(GWidget) || parent.is_a?(CustomWidget)) &&
            parent.widget.is_a?(Combo) &&
            args.size == 1 &&
            args[0].is_a?(ModelBinding) &&
            args[0].evaluate_options_property.is_a?(Array)
        end

        def do_handle(parent, command_symbol, *args, &block)
          model_binding = args[0]
          widget_binding = WidgetBinding.new(parent, "items")
          widget_binding.call(model_binding.evaluate_options_property)
          model = model_binding.base_model
          widget_binding.observe(model, model_binding.options_property_name)

          widget_binding = WidgetBinding.new(parent, "text")
          widget_binding.call(model_binding.evaluate_property)
          widget_binding.observe(model, model_binding.property_name_expression)

          parent.on_widget_selected {
            model_binding.call(widget_binding.evaluate_property)
          }
        end
      end
    end
  end
end
