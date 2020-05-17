require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class TreeProxy < Glimmer::SWT::WidgetProxy
      def select(text:)
        depth_first_search = lambda do |tree_item, found|
          found << tree_item if tree_item.getText == text
          tree_item.getItems.each do |child_tree_item|
            depth_first_search.call(child_tree_item, found)
          end
        end

        found = []
        depth_first_search.call(swt_widget.getItems.first, found)
        
        swt_widget.setSelection(found.to_java(TreeItem))
      end
    end
  end
end
