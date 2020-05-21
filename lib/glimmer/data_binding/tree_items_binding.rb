require 'glimmer/data_binding/observable_array'
require 'glimmer/data_binding/observable_model'
require 'glimmer/data_binding/observable'
require 'glimmer/data_binding/observer'
require 'glimmer/swt/swt_proxy'

module Glimmer
  module DataBinding
    class TreeItemsBinding
      include DataBinding::Observable
      include DataBinding::Observer

      include_package 'org.eclipse.swt'
      include_package 'org.eclipse.swt.widgets'

      def initialize(parent, model_binding, tree_properties)
        @tree = parent
        @model_binding = model_binding
        @tree_properties = [tree_properties].flatten.first.to_h
        if @tree.respond_to?(:tree_properties=)
          @tree.tree_properties = @tree_properties
        else # assume custom widget
          @tree.body_root.tree_properties = @tree_properties
        end
        call
        model = model_binding.base_model
        observe(model, model_binding.property_name_expression)
        @tree.on_widget_disposed do |dispose_event|
          unregister_all_observables
        end
      end

      def call(new_value=nil)
        @model_tree_root_node = @model_binding.evaluate_property
        populate_tree(@model_tree_root_node, @tree, @tree_properties)
      end

      def populate_tree(model_tree_root_node, parent, tree_properties)
        # TODO make it change things by delta instead of removing all
        selected_tree_item_model = parent.swt_widget.getSelection.map(&:getData).first
        parent.all_tree_items.each do |tree_item|
          tree_item.getData('observer_registrations').each do |key, observer_registration|
            observer_registration.unregister
          end
        end
        parent.swt_widget.removeAll
        populate_tree_node(model_tree_root_node, parent.swt_widget, tree_properties)
        tree_item_to_select = parent.depth_first_search {|ti| ti.getData == selected_tree_item_model}
        parent.swt_widget.setSelection(tree_item_to_select)
      end

      def populate_tree_node(model_tree_node, parent, tree_properties)
        return if model_tree_node.nil?
        # TODO anticipate default tree properties if none were passed (like literal values text and children)
        tree_item = TreeItem.new(parent, SWT::SWTProxy[:none])
        observer_registrations = @tree_properties.reduce({}) do |hash, key_value_pair|
          hash.merge(key_value_pair.first => observe(model_tree_node, key_value_pair.last))
        end
        tree_item.setData('observer_registrations', observer_registrations)
        tree_item.setData(model_tree_node)
        tree_item.setText((model_tree_node && model_tree_node.send(tree_properties[:text])).to_s)
        [model_tree_node && model_tree_node.send(tree_properties[:children])].flatten.to_a.compact.each do |child|
          populate_tree_node(child, tree_item, tree_properties)
        end
      end
    end
  end
end
