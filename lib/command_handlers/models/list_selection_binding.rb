require File.dirname(__FILE__) + "/observer"

# SWT List widget selection binding
class ListSelectionBinding
  include Glimmer
  include Observer

  attr_reader :widget
  @@property_type_updaters = {
    :string => lambda { |widget, value| widget.widget.select(widget.widget.index_of(value.to_s)) },
    :array => lambda { |widget, value| widget.widget.selection=((value or []).to_java :string) }
  }
  @@property_evaluators = {
    :string => lambda do |selection_array|
      return nil if selection_array.empty?
      selection_array[0]
     end,
    :array => lambda do |selection_array|
      selection_array
    end
  }
  # Initialize with list widget and property_type
  # property_type :string represents default list single selection
  # property_type :array represents list multi selection
  def initialize(widget, property_type)
    property_type = :string if property_type.nil? or property_type == :undefined
    @widget = widget
    @property_type = property_type
    add_contents(@widget) {
      on_widget_disposed { |dispose_event|
        unregister_all_observables
      }
    }
  end
  def update(value)
    @@property_type_updaters[@property_type].call(@widget, value) unless evaluate_property == value
  end
  def evaluate_property
    selection_array = @widget.widget.send("selection").to_a
    property_value = @@property_evaluators[@property_type].call(selection_array)
    return property_value
  end
end
