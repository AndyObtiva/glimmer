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
  def update(model_tree_root=nil)
    if model_tree_root and model_tree_root.respond_to?(@tree_properties[:children])
      model_tree_root.extend(ObservableModel) unless model_tree_root.is_a?(ObservableModel)
      model_tree_root.add_observer(@tree_properties[:text], self)
      @model_tree_root = model_tree_root
    end
    populate_tree(@model_tree_root, @tree, @tree_properties)
  end
  def populate_tree(model_tree_root, parent, tree_properties)
    parent.widget.removeAll
    populate_tree_node(model_tree_root, parent.widget, tree_properties)
  end
  def populate_tree_node(node, parent, tree_properties)
    table_item = TreeItem.new(parent, SWT::NONE)
    table_item.setText((node && node.send(tree_properties[:text])).to_s)
    [node && node.send(tree_properties[:children])].flatten.to_a.compact.each do |child|
      populate_tree_node(child, table_item, tree_properties)
    end
  end

end
