require 'glimmer'
require 'glimmer/swt/swt_proxy'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.widgets.Layout
    #
    # This is meant to be used with a WidgetProxy where it will
    # set the layout in the SWT widget upon instantiation.
    #
    # Follows the Proxy Design Pattern
    class LayoutProxy
      include_package 'org.eclipse.swt.layout'

      attr_reader :widget_proxy, :swt_layout

      class << self
        include_package 'org.eclipse.swt.widgets'

        def layout_exists?(underscored_layout_name)
          begin
            swt_layout_class_for(underscored_layout_name)
            true
          rescue NameError => e
            false
          end
        end

        # This supports layouts in and out of basic SWT library
        def swt_layout_class_for(underscored_layout_name)
          swt_layout_name = underscored_layout_name.camelcase(:upper)
          swt_layout_class = eval(swt_layout_name)
          unless swt_layout_class.ancestors.include?(Layout)
            raise NameError, "Class #{swt_layout_class} matching #{underscored_layout_name} is not a subclass of org.eclipse.swt.widgets.Layout"
          end
          swt_layout_class
        rescue => e
          Glimmer.logger.debug "#{e.message}\n#{e.backtrace.join("\n")}"
          raise e
        end
      end

      def initialize(underscored_layout_name, widget_proxy, args)
        @underscored_layout_name = underscored_layout_name
        @widget_proxy = widget_proxy
        args = SWTProxy.constantify_args(args)
        @swt_layout = self.class.swt_layout_class_for(underscored_layout_name).new(*args)
        @widget_proxy.swt_widget.setLayout(@swt_layout)
      end

      def has_attribute?(attribute_name, *args)
        @swt_layout.respond_to?(attribute_setter(attribute_name), args)
      end

      def set_attribute(attribute_name, *args)
        apply_property_type_converters(attribute_name, args)
        @swt_layout.send(attribute_setter(attribute_name), *args)
      end

      def apply_property_type_converters(attribute_name, args)
        if args.count == 1 && SWTProxy.has_constant?(args.first)
          args[0] = SWTProxy.constant(args.first)
        end
      end

      def attribute_setter(attribute_name)
        "#{attribute_name.to_s.camelcase(:lower)}="
      end
    end
  end
end
