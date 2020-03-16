require_relative 'observable_array'
require_relative 'observable_model'
require_relative 'observable'
require_relative 'observer'

class TableItemsBinding
  include Glimmer
  include Observable
  include Observer
  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.widgets'

  def initialize(parent, model_binding, column_properties)
    @table = parent
    @model_binding = model_binding
    @column_properties = column_properties
    call(@model_binding.evaluate_property)
    model = model_binding.base_model
    observe(model, model_binding.property_name_expression)
    add_contents(@table) {
      on_widget_disposed { |dispose_event|
        unregister_all_observables
      }
    }
  end
  def call(model_collection=nil)
    if model_collection and model_collection.is_a?(Array)
      observe(model_collection, @column_properties)
      @model_collection = model_collection
    end
    populate_table(@model_collection, @table, @column_properties)
  end
  def populate_table(model_collection, parent, column_properties)
    parent.widget.removeAll
    model_collection.each do |model|
      table_item = TableItem.new(parent.widget, GSWT[:none])
      for index in 0..(column_properties.size-1)
        table_item.setText(index, model.send(column_properties[index]).to_s)
      end
    end
  end

end
