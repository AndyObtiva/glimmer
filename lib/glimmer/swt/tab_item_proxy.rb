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
    # Follows the Proxy Design Pattern
    class TabItemProxy < WidgetProxy
      include_package 'org.eclipse.swt.widgets'

      attr_reader :swt_tab_item

      def initialize(parent, style, &contents)
        super("composite", parent, style, &contents)
        @swt_tab_item = SWT::WidgetProxy.new('tab_item', parent.swt_widget, args)
        @swt_tab_item.swt_widget.control = self.swt_widget
      end

      def has_attribute?(attribute_name, *args)
        if attribute_name.to_s == "text"
          true
        else
          super(attribute_name, *args)
        end
      end

      def set_attribute(attribute_name, *args)
        if attribute_name.to_s == "text"
          text_value = args[0]
          @swt_tab_item.swt_widget.text = text_value
        else
          super(attribute_name, *args)
        end
      end

      def get_attribute(attribute_name)
        if attribute_name.to_s == "text"
          @swt_tab_item.swt_widget.text
        else
          super(attribute_name)
        end
      end
    end
  end
end
