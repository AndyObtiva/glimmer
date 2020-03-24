require 'set'

require_relative 'proc_tracker'

module Glimmer
  module SWT
    module CustomWidget
      include SuperModule
      include Glimmer
      include Parent

      class << self
        def for(underscored_custom_widget_name)
          namespaces = underscored_custom_widget_name.
            to_s.
            split(/__/).map do |namespace|
              namespace.camelcase(:upper)
            end
          custom_widget_class = namespaces.reduce(Object) do |result, namespace|
            result.const_get(namespace.to_sym)
          end
          custom_widget_class if custom_widget_class.ancestors.include?(Glimmer::SWT::CustomWidget)
        rescue => e
          Glimmer.logger.debug "#{e.message}\n#{e.backtrace.join("\n")}"
          nil
        end

        # Allows defining convenience option readers for an array of option names
        # Example: `options :color1, :color2` defines `#color1` and `#color2`
        # where they return the instance values `options[:color1]` and `options[:color2]`
        # respectively.
        # Can be called multiple times to set more options additively.
        # When passed no arguments, it returns list of all option names captured so far
        def options(*new_options)
          new_options = new_options.compact.map(&:to_s)
          if new_options.empty?
            @options ||= Set.new # class options array
          else
            options |= Set[*new_options]
            def_option_attr_readers(new_options)
          end
        end

        def def_option_attr_readers(new_options)
          new_options.each do |option|
            class_eval <<-end_eval, __FILE__, __LINE__
              def #{option}
                options[:#{option}]
              end
            end_eval
          end
        end
      end

      attr_reader :body_root, :widget, :parent, :swt_style, :options, :content

      def initialize(parent, *swt_constants, options, &content)
        @parent = parent
        @swt_style = GSWT[*swt_constants]
        @options = options # instance options hash
        @content = ProcTracker.new(content) if content
        @body_root = body
        @widget = @body_root.widget
      end

      def body
        raise 'Not implemented!'
      end

      def has_attribute?(attribute_name, *args)
        respond_to?(attribute_setter(attribute_name), args) ||
          @body_root.has_attribute?(attribute_name, *args)
      end

      def set_attribute(attribute_name, *args)
        if respond_to?(attribute_setter(attribute_name), args)
          send(attribute_setter(attribute_name), *args)
        else
          @body_root.set_attribute(attribute_name, *args)
        end
      end

      def attribute_setter(attribute_name)
        "#{attribute_name}="
      end

      def process_block(block)
        @content.call if @content && !@content.called?
      end
    end
  end
end
