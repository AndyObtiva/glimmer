require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"
require File.dirname(__FILE__) + "/models/observable_model"
require File.dirname(__FILE__) + "/models/model_binding"
require File.dirname(__FILE__) + "/models/widget_binding"

# Responsible for wiring two-way data-binding for text and selection properties
# on Text, Button, and Spinner widgets.
# Does so by using the output of the bind(model, property) command in the form
# of a ModelBinding, which is then connected to an anonymous widget observer
# (aka widget_data_binder as per widget_data_binders array)
#
# Depends on BindCommandHandler
class DataBindingCommandHandler
  extend Glimmer
  include CommandHandler

  include_package 'org.eclipse.swt.widgets'

  @@widget_data_binders = {
    Java::OrgEclipseSwtWidgets::Text => {
      :text => Proc.new do |rwidget, model_binding|
        add_contents(rwidget) {
          on_modify_text { |modify_event|
            model_binding.update(rwidget.widget.getText)
          }
        }
        end,
      },
      Java::OrgEclipseSwtWidgets::Button => {
        :selection => Proc.new do |rwidget, model_binding|
          add_contents(rwidget) {
            on_widget_selected { |selection_event|
              model_binding.update(rwidget.widget.getSelection)
            }
          }
        end
      },
      Java::OrgEclipseSwtWidgets::Spinner => {
        :selection => Proc.new do |rwidget, model_binding|
          add_contents(rwidget) {
            on_widget_selected { |selection_event|
              model_binding.update(rwidget.widget.getSelection)
            }
          }
        end
      }
    }

    def can_handle?(parent, command_symbol, *args, &block)
      (parent.is_a?(RWidget) and
       args.size == 1 and
       args[0].is_a?(ModelBinding))
    end

    def do_handle(parent, command_symbol, *args, &block)
      model_binding = args[0]
      widget_binding_parameters = [parent, command_symbol.to_s]
      widget_binding = WidgetBinding.new(*widget_binding_parameters)
      widget_binding.update(model_binding.evaluate_property)
      model_binding.add_observer(widget_binding)
      widget_data_binder_map = @@widget_data_binders[parent.widget.class]
      widget_data_binder = widget_data_binder_map[command_symbol.to_s.to_sym] if widget_data_binder_map
      widget_data_binder.call(parent, model_binding) if widget_data_binder
    end

  end
