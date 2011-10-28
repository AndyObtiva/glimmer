require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"
require File.dirname(__FILE__) + "/models/observable_model"
require File.dirname(__FILE__) + "/models/model_observer"
require File.dirname(__FILE__) + "/models/widget_observer"

class DataBindingCommandHandler
  extend Glimmer
  include CommandHandler

  include_package 'org.eclipse.swt.widgets'

  @@widget_data_binders = {
    Java::OrgEclipseSwtWidgets::Text => {
      :text => Proc.new do |rwidget, model_observer|
        add_contents(rwidget) {
          on_modify_text { |modify_event|
            model_observer.update(rwidget.widget.getText)
          }
        }
        end,
      },
      Java::OrgEclipseSwtWidgets::Button => {
        :selection => Proc.new do |rwidget, model_observer|
          add_contents(rwidget) {
            on_widget_selected { |selection_event|
              model_observer.update(rwidget.widget.getSelection)
            }
          }
        end
      },
      Java::OrgEclipseSwtWidgets::Spinner => {
        :selection => Proc.new do |rwidget, model_observer|
          add_contents(rwidget) {
            on_widget_selected { |selection_event|
              model_observer.update(rwidget.widget.getSelection)
            }
          }
        end
      }
    }

    def can_handle?(parent, command_symbol, *args, &block)
      parent.is_a?(RWidget) and
       args.size == 1 and
       args[0].is_a?(ModelObserver)
    end

    def do_handle(parent, command_symbol, *args, &block)
      model_observer = args[0]
      widget_observer = WidgetObserver.new(parent, command_symbol.to_s)
      widget_observer.update(model_observer.evaluate_property)
      model = model_observer.model
      model.extend ObservableModel unless model.is_a?(ObservableModel)
      model.add_observer(model_observer.property_name, widget_observer)
      widget_data_binder_map = @@widget_data_binders[parent.widget.class]
      widget_data_binder = widget_data_binder_map[command_symbol.to_s.to_sym] if widget_data_binder_map
      widget_data_binder.call(parent, model_observer) if widget_data_binder
    end

  end
