require 'glimmer'
require 'glimmer/swt/swt_proxy'

module Glimmer
  module SWT
    # Generic proxy for all SWT layout data objects, such as GridData & RowData
    #
    # This class is meant to be used with an existing WidgetProxy
    # as it figures out the right SWT layout data class name
    # by convention from the parent SWT widget layout class name
    #
    # The convention is:
    # - Start with the parent widget layout package/class name (e.g. org.eclipse.swt.layout.RowLayout)
    # - Replace the word "Layout" with "Data" in the class name
    #
    # Examples of figuring out SWT layout data class:
    # - org.eclipse.swt.layout.RowData for org.eclipse.swt.layout.RowLayout
    # - org.eclipse.swt.layout.GridData for org.eclipse.swt.layout.GridLayout
    #
    # Follows the Proxy Design Pattern
    class LayoutDataProxy
      include_package 'org.eclipse.swt.layout'

      attr_reader :widget_proxy
      attr_reader :swt_layout_data

      # Inititalizes with owning widget proxy and layout data arguments
      def initialize(widget_proxy, args)
        @widget_proxy = widget_proxy
        args = SWTProxy.constantify_args(args)
        begin
          @swt_layout_data = swt_layout_data_class.new(*args)
        rescue => e
          Glimmer.logger&.debug "#{e.message}\n#{e.backtrace.join("\n")}"
          @swt_layout_data = args.first if args.count == 1
        end
        @widget_proxy.swt_widget.setLayoutData(@swt_layout_data)
      end

      # This figures out the right SWT layout data class name
      # by convention from the parent SWT widget layout class name
      #
      # Supports layout data classes in and out of basic SWT library
      #
      # The convention is:
      # - Start with the parent widget layout package/class name (e.g. org.eclipse.swt.layout.RowLayout)
      # - Replace the word "Layout" with "Data" in the class name
      #
      # Examples of figuring out SWT layout data class:
      # - org.eclipse.swt.layout.RowData for org.eclipse.swt.layout.RowLayout
      # - org.eclipse.swt.layout.GridData for org.eclipse.swt.layout.GridLayout
      #
      def swt_layout_data_class
        parent_layout_class_name = @widget_proxy.swt_widget.getParent.getLayout.class.name
        layout_data_class_name = parent_layout_class_name.sub(/Layout$/, 'Data')
        eval(layout_data_class_name)
      end

      def has_attribute?(attribute_name, *args)
        @swt_layout_data.respond_to?(attribute_setter(attribute_name), args)
      end

      def set_attribute(attribute_name, *args)
        args = SWTProxy.constantify_args(args)
        if args.first != @swt_layout_data.send(attribute_getter(attribute_name))
          @swt_layout_data.send(attribute_setter(attribute_name), *args)
          @widget_proxy.swt_widget.getShell.pack
        end
      end

      def get_attribute(attribute_name)
        @swt_layout_data.send(attribute_getter(attribute_name))
      end

      def attribute_setter(attribute_name)
        "#{attribute_name.to_s.camelcase(:lower)}="
      end

      def attribute_getter(attribute_name)
        "#{attribute_name.to_s.camelcase(:lower)}"
      end
    end
  end
end
