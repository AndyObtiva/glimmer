require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class TreeProxy < Glimmer::SWT::WidgetProxy
      # Performs depth first search for tree items matching block condition
      # Returns a Java TreeItem array to easily set as selection on org.eclipse.swt.Tree when needed
      def depth_first_search(&condition)
        found = []
        recursive_depth_first_search(swt_widget.getItems.first, found, &condition)
        found.to_java(TreeItem)
      end

      def widget_property_listener_installers
        super.merge({
          Java::OrgEclipseSwtWidgets::Tree => {
            selection: lambda do |observer|
              on_widget_selected { |selection_event|
                observer.call(@swt_widget.getSelection)
              }
            end
          },        
        })
      end
      
      private

      def recursive_depth_first_search(tree_item, found, &condition)
        found << tree_item if condition.nil? || condition.call(tree_item)
        tree_item.getItems.each do |child_tree_item|
          recursive_depth_first_search(child_tree_item, found, &condition)
        end
      end
      
      def property_type_converters
        super.merge({
          selection: lambda do |value|
            depth_first_search {|ti| ti.getData == value}
          end,
        })
      end
    end
  end
end
