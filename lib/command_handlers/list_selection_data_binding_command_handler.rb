require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"
require File.dirname(__FILE__) + "/models/list_selection_binding"

class ListSelectionDataBindingCommandHandler
  include CommandHandler
  include Glimmer

  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(RWidget) and
    parent.widget.is_a?(List) and
    command_symbol.to_s == "selection" and
    args.size == 1 and
    args[0].is_a?(ModelBinding) and
    args[0].evaluate_options_property.is_a?(Array) and
    block == nil
  end

  def do_handle(parent, command_symbol, *args, &block)
    model_binding = args[0]
    widget_binding = WidgetBinding.new(parent, "items")
    widget_binding.update(model_binding.evaluate_options_property)
    model = model_binding.base_model
    model.extend ObservableModel unless model.is_a?(ObservableModel)
    model.add_observer(model_binding.options_property_name, widget_binding)

    property_type = :string
    property_type = :array if parent.has_style?(:multi)
    list_selection_binding = ListSelectionBinding.new(parent, property_type)
    list_selection_binding.update(model_binding.evaluate_property)
    model.add_observer(model_binding.property_name_expression, list_selection_binding)

    add_contents(parent) {
      on_widget_selected {
        model_binding.update(list_selection_binding.evaluate_property)
      }
    }
  end

end
