################################################################################
# Copyright (c) 2008 Annas Al Maleh.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#    Annas Al Maleh - initial API and implementation
################################################################################ 

require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"
require File.dirname(__FILE__) + "/models/list_observer"

class ListSelectionDataBindingCommandHandler
  include CommandHandler
  include Glimmer
  
  include_package 'org.eclipse.swt.widgets'

  def can_handle?(parent, command_symbol, *args, &block)
    parent.is_a?(RWidget) and
    parent.widget.is_a?(List) and
    command_symbol.to_s == "selection" and
    args.size == 1 and
    args[0].is_a?(ModelObserver) and
    args[0].evaluate_options_property.is_a?(Array) and
    block == nil
  end
  
  def do_handle(parent, command_symbol, *args, &block)
    model_observer = args[0]
    widget_observer = WidgetObserver.new(parent, "items")
    widget_observer.update(model_observer.evaluate_options_property)
    model = model_observer.model
    model.extend ObservableModel unless model.is_a?(ObservableModel)
    model.add_observer(model_observer.options_property_name, widget_observer)

    property_type = :string
    property_type = :array if parent.has_style?(multi)
    list_observer = ListObserver.new(parent, property_type)
    list_observer.update(model_observer.evaluate_property)
    model.add_observer(model_observer.property_name, list_observer)
    
    add_contents(parent) {
      on_widget_selected {
        model_observer.update(list_observer.evaluate_property)
      }
    }
  end

end