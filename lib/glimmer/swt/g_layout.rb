require_relative '../../parent'
require_relative 'g_swt'

module Glimmer
  class GLayout
    include_package 'org.eclipse.swt.layout'

    include Parent

    attr_reader :composite
    attr_reader :layout

    class << self
      include_package 'org.eclipse.swt.layout'

      def layout_exists?(underscored_layout_name)
        begin
          swt_layout_class_for(underscored_layout_name)
          true
        rescue NameError => e
          false
        end
      end

      # This supports layouts in and out of basic SWT
      def swt_layout_class_for(underscored_layout_name)
        swt_layout_name = underscored_layout_name.camelcase(:upper)
        swt_layout_class = eval(swt_layout_name)
        unless swt_layout_class.ancestors.include?(org.eclipse.swt.widgets.Layout)
          raise NameError, "Class #{swt_layout_class} matching #{underscored_layout_name} is not a subclass of org.eclipse.swt.widgets.Layout"
        end
        swt_layout_class
      rescue => e
        Glimmer.logger.debug "#{e.message}\n#{e.backtrace.join("\n")}"
        raise e
      end
    end

    def initialize(underscored_layout_name, composite, args)
      @underscored_layout_name = underscored_layout_name
      @composite = composite
      args = GSWT.constantify_args(args)
      @layout = self.class.swt_layout_class_for(underscored_layout_name).new(*args)
      @composite.setLayout(@layout)
    end

    def process_block(block)
      block.call(@layout)
    end

    def has_attribute?(attribute_name, *args)
      @layout.respond_to?(attribute_setter(attribute_name), args)
    end

    def set_attribute(attribute_name, *args)
      apply_property_type_converters(attribute_name, args)
      @layout.send(attribute_setter(attribute_name), *args)
    end

    def apply_property_type_converters(attribute_name, args)
      if args.count == 1 && GSWT.has_constant?(args.first)
        args[0] = GSWT.constant(args.first)
      end
    end

    def attribute_setter(attribute_name)
      "#{attribute_name.to_s.camelcase(:lower)}="
    end

  end
end
