require 'glimmer'
require 'glimmer/error'
require 'glimmer/swt/swt_proxy'
require 'glimmer/swt/display_proxy'
require 'glimmer/util/proc_tracker'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_model'
require 'glimmer/data_binding/observable_widget'

module Glimmer
  module UI
    module CustomWidget
      include SuperModule
      include DataBinding::ObservableModel

      super_module_included do |klass|
        klass.include(Glimmer) unless klass.name.include?('Glimmer::UI::CustomShell')
        klass.prepend DataBinding::ObservableWidget
        Glimmer::UI::CustomWidget.add_custom_widget_namespaces_for(klass) unless klass.name.include?('Glimmer::UI::CustomShell')
      end

      class << self
        def for(underscored_custom_widget_name)
          extracted_namespaces = underscored_custom_widget_name.
            to_s.
            split(/__/).map do |namespace|
              namespace.camelcase(:upper)
            end
          custom_widget_namespaces.each do |base|
            extracted_namespaces.reduce(base) do |result, namespace|
              if !result.constants.include?(namespace)
                namespace = result.constants.detect {|c| c.to_s.upcase == namespace.to_s.upcase } || namespace
              end
              begin
                constant = result.const_get(namespace)
                return constant if constant.ancestors.include?(Glimmer::UI::CustomWidget)
                constant
              rescue => e
                # Glimmer::Config.logger&.debug "#{e.message}\n#{e.backtrace.join("\n")}"
                result
              end
            end
          end
          raise "#{underscored_custom_widget_name} has no custom widget class!"
        rescue => e
          Glimmer::Config.logger&.debug e.message
          Glimmer::Config.logger&.debug "#{e.message}\n#{e.backtrace.join("\n")}"
          nil
        end
 
        def add_custom_widget_namespaces_for(klass)
          Glimmer::UI::CustomWidget.namespaces_for_class(klass).drop(1).each do |namespace|
            Glimmer::UI::CustomWidget.custom_widget_namespaces << namespace
          end
        end

        def namespaces_for_class(m)
          return [m] if m.name.nil?
          namespace_constants = m.name.split(/::/).map(&:to_sym)
          namespace_constants.reduce([Object]) do |output, namespace_constant|
            output += [output.last.const_get(namespace_constant)]
          end[1..-1].uniq.reverse
        end

        def custom_widget_namespaces
          @custom_widget_namespaces ||= reset_custom_widget_namespaces
        end

        def reset_custom_widget_namespaces
          @custom_widget_namespaces = Set[Object, Glimmer::UI]
        end

        # Allows defining convenience option accessors for an array of option names
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
            new_options = new_options.reduce({}) {|new_options_hash, new_option| new_options_hash.merge(new_option => nil)}
            @options = options.merge(new_options)
            def_option_attr_accessors(new_options)
          end
        end

        def option(new_option, default: nil)
          new_option = new_option.to_s.to_sym
          new_options = {new_option => default}
          @options = options.merge(new_options)
          def_option_attr_accessors(new_options)
        end

        def def_option_attr_accessors(new_options)
          new_options.each do |option, default|
            class_eval <<-end_eval, __FILE__, __LINE__
              def #{option}
                options[:#{option}]
              end
              def #{option}=(option_value)
                self.options[:#{option}] = option_value
              end
            end_eval
          end
        end

        def before_body(&block)
          @before_body_blocks ||= []
          @before_body_blocks << block
        end

        def body(&block)
          @body_block = block
        end

        def after_body(&block)
          @after_body_blocks ||= []
          @after_body_blocks << block
        end
      end

      attr_reader :body_root, :swt_widget, :parent, :swt_style, :options

      def initialize(parent, *swt_constants, options, &content)
        @parent = parent
        @swt_style = SWT::SWTProxy[*swt_constants]
        options ||= {}
        @options = self.class.options.merge(options)
        @content = Util::ProcTracker.new(content) if content
        execute_hooks('before_body')
        body_block = self.class.instance_variable_get("@body_block")
        raise Glimmer::Error, 'Invalid custom widget for having no body! Please define body block!' if body_block.nil?
        @body_root = instance_exec(&body_block)
        execute_hooks('after_body')
        @swt_widget = @body_root.swt_widget
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
          property = observation_request.sub(/^on_updated_/, '') # TODO look into eliminating duplication from above
          add_observer(DataBinding::Observer.proc(&block), property) if can_add_observer?(property)
        else
          body_root.handle_observation_request(observation_request, &block)
        end
      end

      def can_add_observer?(attribute_name)
        has_instance_method?(attribute_name) || respond_to?("#{attribute_name}?") || @body_root.can_add_observer?(attribute_name)
      end

      def add_observer(observer, attribute_name)
        if has_instance_method?(attribute_name)
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

      # This method ensures it has an instance method not coming from Glimmer DSL
      def has_instance_method?(method_name)
        respond_to?(method_name) && !method(method_name)&.source_location&.first&.include?('glimmer/dsl/engine.rb')
      end

      def get_attribute(attribute_name)
        if has_instance_method?(attribute_name)
          send(attribute_name)
        else
          @body_root.get_attribute(attribute_name)
        end
      end

      def attribute_setter(attribute_name)
        "#{attribute_name}="
      end


      def has_style?(style)
        (swt_style & SWT::SWTProxy[style]) == SWT::SWTProxy[style]
      end

      # TODO see if it is worth it to eliminate duplication of async_exec/sync_exec
      # delegation to DisplayProxy, via a module

      def async_exec(&block)
        SWT::DisplayProxy.instance.async_exec(&block)
      end

      def sync_exec(&block)
        SWT::DisplayProxy.instance.sync_exec(&block)
      end

      # Returns content block if used as an attribute reader (no args)
      # Otherwise, if a block is passed, it adds it as content to this custom widget
      def content(&block)
        if block_given?
          body_root.content(&block)
        else
          @content
        end
      end

      def dispose
        body_root.dispose
      end
      
      def method_missing(method, *args, &block)
        body_root.send(method, *args, &block)
      end

      private

      def execute_hooks(hook_name)
        self.class.instance_variable_get("@#{hook_name}_blocks")&.each do |hook_block|
          instance_exec(&hook_block)
        end
      end
    end
  end
end
