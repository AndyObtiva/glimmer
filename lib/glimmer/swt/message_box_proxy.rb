require 'glimmer/swt/swt_proxy'
require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/display_proxy'
require 'glimmer/swt/shell_proxy'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.widgets.Shell
    #
    # Follows the Proxy Design Pattern
    class MessageBoxProxy
      include_package 'org.eclipse.swt.widgets'
      
      attr_reader :swt_widget
      
      def initialize(parent, style)
        parent = parent.swt_widget if parent.respond_to?(:swt_widget) && parent.swt_widget.is_a?(Shell)
        @swt_widget = MessageBox.new(parent, style)
      end
      
      # TODO refactor the following methods to put in a JavaBean mixin or somethin (perhaps contribute to OSS project too)
      
      def attribute_setter(attribute_name)
        "set#{attribute_name.to_s.camelcase(:upper)}"
      end

      def attribute_getter(attribute_name)
        "get#{attribute_name.to_s.camelcase(:upper)}"
      end
      
      def has_attribute?(attribute_name, *args)
        @swt_widget.respond_to?(attribute_setter(attribute_name), args)
      end

      def set_attribute(attribute_name, *args)
        @swt_widget.send(attribute_setter(attribute_name), *args) unless @swt_widget.send(attribute_getter(attribute_name)) == args.first
      end

      def get_attribute(attribute_name)
        @swt_widget.send(attribute_getter(attribute_name))
      end      
    end
  end
end
