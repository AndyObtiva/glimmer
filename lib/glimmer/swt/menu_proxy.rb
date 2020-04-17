require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.widgets.Menu
    #
    # Functions differently from other widget proxies.
    #
    # Glimmer automatically detects if this is a drop down menu
    # or pop up menu from its parent if no SWT style is passed in.
    #
    # There are 3 possibilities:
    # - SWT :bar style is passed in: Menu Bar
    # - Parent is ShellProxy: Pop Up Menu (having style :pop_up)
    # - Parent is another Menu: Drop Down Menu (having style :drop_down)
    #
    # In order to get the SWT Menu object, one must call `#swt_widget`.
    #
    # In the case of a Drop Down menu, this automatically creates an
    # SWT MenuItem object with style :cascade
    #
    # In order to retrieve the menu item widget proxy, one must call `#menu_item_proxy`
    #
    # Follows the Proxy Design Pattern
    class MenuProxy < WidgetProxy
      include_package 'org.eclipse.swt.widgets'

      attr_reader :menu_item_proxy, :swt_menu_item, :menu_parent

      def initialize(parent, args)
        index = args.delete(args.last) if args.last.is_a?(Numeric)
        styles = args.map(&:to_sym)
        if !styles.include?(:bar) && !parent.swt_widget.is_a?(Menu)
          styles = styles.unshift(:pop_up)
        end

        swt_widget_class = self.class.swt_widget_class_for('menu')
        if parent.swt_widget.is_a?(Menu)
          @menu_item_proxy = SWT::WidgetProxy.new('menu_item', parent, [:cascade] + [index].compact)
          @swt_menu_item = @menu_item_proxy.swt_widget
          @swt_widget = swt_widget_class.new(@menu_item_proxy.swt_widget)
          @swt_menu_item.setMenu(swt_widget)
        elsif parent.swt_widget.is_a?(Shell)
          @swt_widget = swt_widget_class.new(parent.swt_widget, style('menu', styles))
        else
          @swt_widget = swt_widget_class.new(parent.swt_widget)
        end
        DEFAULT_INITIALIZERS['menu']&.call(swt_widget)

        if styles.include?(:bar)
          parent.swt_widget.setMenuBar(swt_widget)
        elsif styles.include?(:pop_up)
          parent.swt_widget.setMenu(swt_widget)
        end
      end

      def has_attribute?(attribute_name, *args)
        if attribute_name.to_s == "text"
          true
        else
          super(attribute_name, *args)
        end
      end

      def set_attribute(attribute_name, *args)
        attribute_name
        if attribute_name.to_s == "text"
          text_value = args[0]
          @swt_menu_item.setText text_value
        else
          super(attribute_name, *args)
        end
      end

      def get_attribute(attribute_name)
        if attribute_name.to_s == "text"
          @swt_menu_item.getText
        else
          super(attribute_name)
        end
      end
    end
  end
end
