require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.widgets.TabItem
    #
    # Functions differently from other widget proxies.
    #
    # Glimmer instantiates an SWT Composite alongside the SWT TabItem
    # and returns it for `#swt_widget` to allow adding widgets into it.
    #
    # In order to get the SWT TabItem object, one must call `#swt_tab_item`.
    #
    # Behind the scenes, this creates a tab item widget proxy separately from a composite that
    # is set as the control of the tab item and `#swt_widget`.
    #
    # In order to retrieve the tab item widget proxy, one must call `#widget_proxy`
    #
    # Follows the Proxy Design Pattern
    class TabItemProxy < WidgetProxy
      include_package 'org.eclipse.swt.widgets'

      attr_reader :widget_proxy, :swt_tab_item

      def initialize(parent, style, &contents)
        super("composite", parent, style, &contents)
        @widget_proxy = SWT::WidgetProxy.new('tab_item', parent, style)
        @swt_tab_item = @widget_proxy.swt_widget
        @widget_proxy.swt_widget.control = self.swt_widget
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
          @swt_tab_item.setText text_value
        else
          super(attribute_name, *args)
        end
      end

      def get_attribute(attribute_name)
        if attribute_name.to_s == "text"
          @swt_tab_item.getText
        else
          super(attribute_name)
        end
      end
      
      def dispose
        swt_tab_item.setControl(nil)
        swt_widget.dispose
        swt_tab_item.dispose
      end
    end
  end
end
