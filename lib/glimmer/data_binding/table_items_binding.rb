require 'glimmer/data_binding/observable_array'
require 'glimmer/data_binding/observable_model'
require 'glimmer/data_binding/observable'
require 'glimmer/data_binding/observer'
require 'glimmer/swt/swt_proxy'

module Glimmer
  module DataBinding
    class TableItemsBinding
      include DataBinding::Observable
      include DataBinding::Observer
      include_package 'org.eclipse.swt'
      include_package 'org.eclipse.swt.widgets'

      def initialize(parent, model_binding, column_properties)
        @table = parent
        @model_binding = model_binding
        @column_properties = column_properties
        call(@model_binding.evaluate_property)
        model = model_binding.base_model
        observe(model, model_binding.property_name_expression)
        @table.on_widget_disposed do |dispose_event|
          unregister_all_observables
        end
      end

      def call(new_model_collection=nil)
        if new_model_collection and new_model_collection.is_a?(Array)
          observe(new_model_collection, @column_properties)
          @model_collection = new_model_collection
        end
        populate_table(@model_collection, @table, @column_properties)
      end

      def populate_table(model_collection, parent, column_properties)
        selected_table_item_model = parent.swt_widget.getSelection.first&.getData
        parent.swt_widget.removeAll
        model_collection.each do |model|
          table_item = TableItem.new(parent.swt_widget, SWT::SWTProxy[:none])
          for index in 0..(column_properties.size-1)
            table_item.setText(index, model.send(column_properties[index]).to_s)
          end
          table_item.setData(model)
        end
        selected_table_item = parent.search {|item| item.getData == selected_table_item_model}.first || parent.swt_widget.getItems.first
        parent.swt_widget.setSelection([selected_table_item].to_java(TableItem)) if selected_table_item
      end
    end
  end
end
