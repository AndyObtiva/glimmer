require File.dirname(__FILE__) + "/observable_array"
require File.dirname(__FILE__) + "/observable_model"

class TreeItemsUpdater
  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.widgets'

  def initialize(parent, model_observer, tree_properties)
    @tree = parent
    @model_observer = model_observer
    @tree_properties = [tree_properties].flatten.first.to_h
    update(@model_observer.evaluate_property)
    model = model_observer.model
    model.extend(ObservableModel) unless model.is_a?(ObservableModel)
    model.add_observer(model_observer.property_name, self)
  end
  def update(model_tree_root_node=nil)
    if model_tree_root_node and model_tree_root_node.respond_to?(@tree_properties[:children])
      model_tree_root_node.extend(ObservableModel) unless model_tree_root_node.is_a?(ObservableModel)
      model_tree_root_node.add_observer(@tree_properties[:text], self)
      model_tree_root_node.add_observer(@tree_properties[:children], self)
      @model_tree_root_node = model_tree_root_node
    end
    populate_tree(@model_tree_root_node, @tree, @tree_properties)
  end
  def populate_tree(model_tree_root_node, parent, tree_properties)
    parent.widget.removeAll
    populate_tree_node(model_tree_root_node, parent.widget, tree_properties)
  end
  def populate_tree_node(model_tree_node, parent, tree_properties)
    table_item = TreeItem.new(parent, SWT::NONE)
    table_item.setText((model_tree_node && model_tree_node.send(tree_properties[:text])).to_s)
      [model_tree_node && model_tree_node.send(tree_properties[:children])].flatten.to_a.compact.each do |child|
      child.extend(ObservableModel) unless child.is_a?(ObservableModel)
      child.add_observer(@tree_properties[:text], self)
      populate_tree_node(child, table_item, tree_properties)
    end
  end

end
