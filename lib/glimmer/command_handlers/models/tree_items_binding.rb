require_relative 'observable_array'
require_relative 'observable_model'
require_relative 'observable'
require_relative 'observer'

module Glimmer
  class TreeItemsBinding
    include Glimmer
    include Observable
    include Observer
    include_package 'org.eclipse.swt'
    include_package 'org.eclipse.swt.widgets'

    def initialize(parent, model_binding, tree_properties)
      @tree = parent
      @model_binding = model_binding
      @tree_properties = [tree_properties].flatten.first.to_h
      call(@model_binding.evaluate_property)
      model = model_binding.base_model
      observe(model, model_binding.property_name_expression)
      add_contents(@tree) {
        on_widget_disposed { |dispose_event|
          unregister_all_observables
        }
      }
    end
    def call(model_tree_root_node=nil)
      if model_tree_root_node and model_tree_root_node.respond_to?(@tree_properties[:children])
        observe(model_tree_root_node, @tree_properties[:text])
        observe(model_tree_root_node, @tree_properties[:children])
        @model_tree_root_node = model_tree_root_node
      end
      populate_tree(@model_tree_root_node, @tree, @tree_properties)
    end
    def populate_tree(model_tree_root_node, parent, tree_properties)
      parent.widget.removeAll
      populate_tree_node(model_tree_root_node, parent.widget, tree_properties)
    end
    def populate_tree_node(model_tree_node, parent, tree_properties)
      table_item = TreeItem.new(parent, GSWT[:none])
      table_item.setText((model_tree_node && model_tree_node.send(tree_properties[:text])).to_s)
      [model_tree_node && model_tree_node.send(tree_properties[:children])].flatten.to_a.compact.each do |child|
        observe(child, @tree_properties[:text])
        populate_tree_node(child, table_item, tree_properties)
      end
    end

  end
end
