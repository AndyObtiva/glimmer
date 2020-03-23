require_relative '../../parent'
require_relative 'g_swt'

module Glimmer
  class GLayoutData
    include_package 'org.eclipse.swt.layout'

    include Parent

    attr_reader :widget
    attr_reader :layout_data

    def initialize(widget, args)
      @widget = widget
      args = GSWT.constantify_args(args)
      begin
        @layout_data = swt_layout_data_class.new(*args)
      rescue => e
        Glimmer.logger.debug "#{e.message}\n#{e.backtrace.join("\n")}"
        @layout_data = args.first if args.count == 1 
      end
      @widget.setLayoutData(@layout_data)
    end

    def process_block(block)
      block.call(@layout)
    end

    def swt_layout_data_class
      parent_layout_class_name = @widget.getParent.getLayout.class.name
      layout_data_class_name = parent_layout_class_name.sub(/Layout$/, 'Data')
      eval(layout_data_class_name)
    end

    def has_attribute?(attribute_name, *args)
      @layout_data.respond_to?(attribute_setter(attribute_name), args)
    end

    def set_attribute(attribute_name, *args)
      apply_property_type_converters(attribute_name, args)
      @layout_data.send(attribute_setter(attribute_name), *args)
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
