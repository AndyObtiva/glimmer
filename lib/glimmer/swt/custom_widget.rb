require_relative 'proc_tracker'
require_relative 'observable_model'

module Glimmer
  module SWT
    module CustomWidget
      include SuperModule
      include Glimmer
      include Parent
      include ObservableModel

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
          new_options = new_options.compact.map(&:to_s).map(&:to_sym)
          if new_options.empty?
            @options ||= {} # maps options to defaults
          else
            new_options = new_options.reduce({}) {|new_options, new_option| new_options.merge(new_option => nil)}
            @options = options.merge(new_options)
            def_option_attr_readers(new_options)
          end
        end

        def option(new_option, new_option_default = nil)
          new_option = new_option.to_s.to_sym
          new_options = {new_option => new_option_default}
          @options = options.merge(new_options)
          def_option_attr_readers(new_options)
        end

        def def_option_attr_readers(new_options)
          new_options.each do |option, default|
            class_eval <<-end_eval, __FILE__, __LINE__
              def #{option}
                options[:#{option}]
              end
            end_eval
          end
        end

        def before_body(&block)
          @before_body_blocks ||= []
          @before_body_blocks << block
        end

        def after_body(&block)
          @after_body_blocks ||= []
          @after_body_blocks << block
        end
      end

      attr_reader :body_root, :widget, :parent, :swt_style, :options, :content

      def initialize(parent, *swt_constants, options, &content)
        @parent = parent
        @swt_style = GSWT[*swt_constants]
        options ||= {}
        @options = self.class.options.merge(options)
        @content = ProcTracker.new(content) if content
        execute_hooks('before_body')
        @body_root = body
        execute_hooks('after_body')
        @widget = @body_root.widget
      end

      def body
        raise 'Not implemented!'
      end

      def can_handle_observation_request?(observation_request)
        result = false
        if observation_request.start_with?('on_updated_')
          property = observation_request.sub(/^on_updated_/, '')
          result = can_add_observer?(property)
        end
        result || body_root&.can_handle_observation_request?(observation_request)
      end

      def handle_observation_request(observation_request, &block)
        if observation_request.start_with?('on_updated_')
          property = observation_request.sub(/^on_updated_/, '')
          add_observer(Observer::Proc.new(&block), property) if can_add_observer?(property)
        else
          body_root.handle_observation_request(observation_request, &block)
        end
      end

      def can_add_observer?(attribute_name)
        respond_to?(attribute_name) || @body_root.can_add_observer?(attribute_name)
      end

      def add_observer(observer, attribute_name)
        if respond_to?(attribute_name)
          super
        else
          @body_root.add_observer(observer, attribute_name)
        end
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

      def get_attribute(attribute_name)
        if respond_to?(attribute_name)
          send(attribute_name)
        else
          @body_root.get_attribute(attribute_name)
        end
      end

      def attribute_setter(attribute_name)
        "#{attribute_name}="
      end

      # TODO see if it is worth it to eliminate duplication of method_missing
      # from GWidget using a module

      def method_missing(method, *args, &block)
        method_name = method.to_s
        if can_handle_observation_request?(method_name)
          handle_observation_request(method_name, &block)
        else
          super
        end
      end

      def process_block(block)
        if block.source_location == @content&.__getobj__.source_location
          @content.call unless @content.called?
        else
          block.call
        end
      end

      def has_style?(style)
        (swt_style & GSWT[style]) == GSWT[style]
      end

      # TODO see if it is worth it to eliminate duplication of async_exec/sync_exec
      # delegation to GDisplay, via a module

      def async_exec(&block)
        GDisplay.instance.async_exec(&block)
      end

      def sync_exec(&block)
        GDisplay.instance.sync_exec(&block)
      end

      private

      def execute_hooks(hook_name)
        self.class.instance_variable_get("@#{hook_name}_blocks")&.each_with_index do |hook_block, i|
          hook_block_number = i + 1
          self.class.define_method("__#{hook_name}#{hook_block_number}", hook_block)
          send("__#{hook_name}#{hook_block_number}")
          self.class.send(:undef_method, "__#{hook_name}#{hook_block_number}")
        end
      end
    end
  end
end
