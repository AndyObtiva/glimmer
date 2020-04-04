require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_widget"
require File.dirname(__FILE__) + "/../custom_widget"
require File.dirname(__FILE__) + "/../observable_model"
require File.dirname(__FILE__) + "/../model_binding"
require File.dirname(__FILE__) + "/../widget_binding"

module Glimmer
  module SWT
    module CommandHandlers
      # Responsible for wiring two-way data-binding for text and selection properties
      # on Text, Button, and Spinner widgets.
      # Does so by using the output of the bind(model, property) command in the form
      # of a ModelBinding, which is then connected to an anonymous widget observer
      # (aka widget_data_binder as per widget_data_binders array)
      #
      # Depends on BindCommandHandler
      class DataBindingCommandHandler
        include CommandHandler

        include_package 'org.eclipse.swt.widgets'

        def can_handle?(parent, command_symbol, *args, &block)
          (parent.is_a?(GWidget) || parent.is_a?(CustomWidget)) and
          args.size == 1 and
          args[0].is_a?(ModelBinding)
        end

        def do_handle(parent, command_symbol, *args, &block)
          model_binding = args[0]
          widget_binding_parameters = [parent, command_symbol.to_s]
          widget_binding = WidgetBinding.new(*widget_binding_parameters)
          widget_binding.call(model_binding.evaluate_property)
          widget_binding.observe(model_binding)
          parent.add_observer(model_binding, command_symbol.to_s.to_sym) #TODO consider reversing statement
        end
      end
    end
  end
end
