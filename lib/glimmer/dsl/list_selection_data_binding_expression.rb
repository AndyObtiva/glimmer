require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_widget"
require File.dirname(__FILE__) + "/../custom_widget"
require File.dirname(__FILE__) + "/../list_selection_binding"

module Glimmer
  module SWT
    module CommandHandlers
      class ListSelectionDataBindingCommandHandler
        include CommandHandler
        include Glimmer

        include_package 'org.eclipse.swt.widgets'

        def can_handle?(parent, command_symbol, *args, &block)
          command_symbol.to_s == "selection" &&
            block == nil &&
            (parent.is_a?(GWidget) || parent.is_a?(CustomWidget)) &&
            parent.widget.is_a?(List) &&
            args.size == 1 &&
            args[0].is_a?(ModelBinding) &&
            args[0].evaluate_options_property.is_a?(Array)
        end

        def do_handle(parent, command_symbol, *args, &block)
          model_binding = args[0]
          widget_binding = WidgetBinding.new(parent, "items")
          widget_binding.call(model_binding.evaluate_options_property)
          model = model_binding.base_model
          #TODO make this options observer dependent and all similar observers in widget specific data binding handlers
          widget_binding.observe(model, model_binding.options_property_name)

          property_type = :string
          property_type = :array if parent.has_style?(:multi)
          list_selection_binding = ListSelectionBinding.new(parent, property_type)
          list_selection_binding.call(model_binding.evaluate_property)
          #TODO check if nested data binding works for list widget and other widgets that need custom data binding
          list_selection_binding.observe(model, model_binding.property_name_expression)

          parent.on_widget_selected {
            model_binding.call(list_selection_binding.evaluate_property)
          }
        end
      end
    end
  end
end
