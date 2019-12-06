require File.dirname(__FILE__) + "/observable_array"
require File.dirname(__FILE__) + "/observable_model"
require File.dirname(__FILE__) + "/observer"

class TableItemsBinding
  include Observer
  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.widgets'

  def initialize(parent, model_binding, column_properties)
    @table = parent
    @model_binding = model_binding
    @column_properties = column_properties
    update(@model_binding.evaluate_property)
    model = model_binding.model
    model.extend(ObservableModel) unless model.is_a?(ObservableModel)
    model.add_observer(model_binding.property_name, self)
  end
  def update(model_collection=nil)
    if model_collection and model_collection.is_a?(Array)
      model_collection.extend(ObservableArray) unless model_collection.is_a?(ObservableArray)
      model_collection.add_observer(@column_properties, self)
      @model_collection = model_collection
    end
    populate_table(@model_collection, @table, @column_properties)
  end
  def populate_table(model_collection, parent, column_properties)
    parent.widget.removeAll
    model_collection.each do |model|
      table_item = TableItem.new(parent.widget, SWT::NONE)
      for index in 0..(column_properties.size-1)
        table_item.setText(index, model.send(column_properties[index]).to_s)
      end
    end
  end

end
