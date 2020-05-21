require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class TreeProxy < Glimmer::SWT::WidgetProxy
      include Glimmer
      
      attr_reader :tree_editor, :tree_editor_text_proxy
      attr_accessor :tree_properties
      
      def initialize(underscored_widget_name, parent, args)
        super
        @tree_editor = TreeEditor.new(swt_widget)
        @tree_editor.horizontalAlignment = SWTProxy[:left]
        @tree_editor.grabHorizontal = true
        @tree_editor.minimumHeight = 20
      end
    
      # Performs depth first search for tree items matching block condition
      # If no condition block is passed, returns all tree items
      # Returns a Java TreeItem array to easily set as selection on org.eclipse.swt.Tree if needed
      def depth_first_search(&condition)
        found = []
        recursive_depth_first_search(swt_widget.getItems.first, found, &condition)
        found.to_java(TreeItem)
      end
      
      # Returns all tree items including descendants
      def all_tree_items
        depth_first_search
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
      
      def edit_selected_tree_item(after_write: nil, after_cancel: nil)
        edit_tree_item(swt_widget.getSelection.first, after_write: after_write, after_cancel: after_cancel)
      end
            
      def edit_tree_item(tree_item, after_write: nil, after_cancel: nil)
        return if tree_item.nil?
        content {
          @tree_editor_text_proxy = text {
            focus true
            text tree_item.getText
            action_taken = false
            action = lambda { |event|
              if !action_taken
                action_taken = true
                new_text = @tree_editor_text_proxy.swt_widget.getText
                if new_text == tree_item.getText
                  @tree_editor_text_proxy.swt_widget.dispose
                  @tree_editor_text_proxy = nil
                  after_cancel&.call
                else
                  tree_item.setText(new_text)
                  model = tree_item.getData
                  model.send("#{tree_properties[:text]}=", new_text) # makes tree update itself, so must search for selected tree item again
                  tree_item = depth_first_search { |ti| ti.getData == model }
                  swt_widget.showItem(tree_item.first)
                  @tree_editor_text_proxy.swt_widget.dispose
                  @tree_editor_text_proxy = nil
                  after_write&.call
                end
              end
            }
            on_focus_lost(&action)
            on_key_pressed { |key_event|
              if key_event.keyCode == swt(:cr)
                action.call(key_event)
              elsif key_event.keyCode == swt(:esc)
                @tree_editor_text_proxy.swt_widget.dispose
                @tree_editor_text_proxy = nil
                after_cancel&.call
              end
            }
          }
          @tree_editor_text_proxy.swt_widget.selectAll
        }
        @tree_editor.setEditor(@tree_editor_text_proxy.swt_widget, tree_item);      
      end
      
      private

      def recursive_depth_first_search(tree_item, found, &condition)
        return if tree_item.nil?
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
