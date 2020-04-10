require 'glimmer'
require 'glimmer/swt/widget_listener_proxy'
require 'glimmer/swt/color_proxy'
require 'glimmer/swt/font_proxy'
require 'glimmer/swt/swt_proxy'
require 'glimmer/data_binding/observable_widget'
require 'glimmer/dsl/widget_expression'

module Glimmer
  module SWT
    # Proxy for SWT Widget objects
    #
    # Sets default SWT styles to widgets upon inititalizing as
    # per DEFAULT_STYLES
    #
    # Also, auto-initializes widgets as per initializer blocks
    # in DEFAULT_INITIALIZERS  (e.g. setting Composite default layout)
    #
    # Follows the Proxy Design Pattern
    class WidgetProxy
      include Packages
      include DataBinding::ObservableWidget

      DEFAULT_STYLES = {
        "text"    => [:border],
        "table"   => [:border],
        "spinner" => [:border],
        "list"    => [:border, :v_scroll],
        "button"  => [:push],
      }

      DEFAULT_INITIALIZERS = {
        "composite" => proc do |composite|
          composite.setLayout(GridLayout.new)
        end,
        "table" => proc do |table|
          table.setHeaderVisible(true)
          table.setLinesVisible(true)
        end,
        "table_column" => proc do |table_column|
          table_column.setWidth(80)
        end,
        "group" => proc do |group|
          group.setLayout(GridLayout.new)
        end,
      }

      attr_reader :swt_widget

      # Initializes a new SWT Widget
      #
      # Styles is a comma separate list of symbols representing SWT styles in lower case
      def initialize(underscored_widget_name, parent, styles, &contents)
        swt_widget_class = self.class.swt_widget_class_for(underscored_widget_name)
        @swt_widget = swt_widget_class.new(parent.swt_widget, style(underscored_widget_name, styles))
        DEFAULT_INITIALIZERS[underscored_widget_name]&.call(@swt_widget)
      end

      def has_attribute?(attribute_name, *args)
        widget_custom_attribute = widget_custom_attribute_mapping[attribute_name.to_s]
        if widget_custom_attribute
          @swt_widget.respond_to?(widget_custom_attribute[:setter][:name])
        else
          @swt_widget.respond_to?(attribute_setter(attribute_name), args)
        end
      end

      def set_attribute(attribute_name, *args)
        widget_custom_attribute = widget_custom_attribute_mapping[attribute_name.to_s]
        if widget_custom_attribute
          widget_custom_attribute[:setter][:invoker].call(@swt_widget, args)
        else
          apply_property_type_converters(attribute_name, args)
          @swt_widget.send(attribute_setter(attribute_name), *args)
        end
      end

      def get_attribute(attribute_name)
        widget_custom_attribute = widget_custom_attribute_mapping[attribute_name.to_s]
        if widget_custom_attribute
          @swt_widget.send(widget_custom_attribute[:getter][:name])
        else
          @swt_widget.send(attribute_getter(attribute_name))
        end
      end

      def widget_property_listener_installers
        @swt_widget_property_listener_installers ||= {
          Java::OrgEclipseSwtWidgets::Control => {
            :focus => proc do |observer|
              on_focus_gained { |focus_event|
                observer.call(true)
              }
              on_focus_lost { |focus_event|
                observer.call(false)
              }
            end,
          },
          Java::OrgEclipseSwtWidgets::Text => {
            :text => proc do |observer|
              on_modify_text { |modify_event|
                observer.call(@swt_widget.getText)
              }
            end,
          },
          Java::OrgEclipseSwtWidgets::Button => {
            :selection => proc do |observer|
              on_widget_selected { |selection_event|
                observer.call(@swt_widget.getSelection)
              }
            end
          },
          Java::OrgEclipseSwtWidgets::Spinner => {
            :selection => proc do |observer|
              on_widget_selected { |selection_event|
                observer.call(@swt_widget.getSelection)
              }
            end
          }
        }
      end

      def self.widget_exists?(underscored_widget_name)
        !!swt_widget_class_for(underscored_widget_name)
      end

      # This supports widgets in and out of basic SWT
      def self.swt_widget_class_for(underscored_widget_name)
        swt_widget_name = underscored_widget_name.camelcase(:upper)
        swt_widget_class = eval(swt_widget_name)
        unless swt_widget_class.ancestors.include?(org.eclipse.swt.widgets.Widget)
          Glimmer.logger.debug("Class #{swt_widget_class} matching #{underscored_widget_name} is not a subclass of org.eclipse.swt.widgets.Widget")
          return nil
        end
        swt_widget_class
      rescue NameError => e
        Glimmer.logger.debug e.message
        # Glimmer.logger.debug("#{e.message}\n#{e.backtrace.join("\n")}")
        nil
      rescue => e
        Glimmer.logger.debug e.message
        # Glimmer.logger.debug("#{e.message}\n#{e.backtrace.join("\n")}")
        nil
      end

      def async_exec(&block)
        DisplayProxy.instance.async_exec(&block)
      end

      def sync_exec(&block)
        DisplayProxy.instance.sync_exec(&block)
      end

      def has_style?(style)
        (@swt_widget.style & SWTProxy[style]) == SWTProxy[style]
      end

      def dispose
        @swt_widget.dispose
      end

      # TODO Consider renaming these methods as they are mainly used for data-binding

      def can_add_observer?(property_name)
        @swt_widget.class.ancestors.map {|ancestor| widget_property_listener_installers[ancestor]}.compact.map(&:keys).flatten.map(&:to_s).include?(property_name.to_s)
      end

      # Used for data-binding only. Consider renaming or improving to avoid the confusion it causes
      def add_observer(observer, property_name)
        property_listener_installers = @swt_widget.class.ancestors.map {|ancestor| widget_property_listener_installers[ancestor]}.compact
        widget_listener_installers = property_listener_installers.map{|installer| installer[property_name.to_s.to_sym]}.compact if !property_listener_installers.empty?
        widget_listener_installers.each do |widget_listener_installer|
          widget_listener_installer.call(observer)
        end
      end

      def remove_observer(observer, property_name)
        # TODO consider implementing if remove_observer is needed (consumers can remove listener via SWT API)
      end

      # TODO eliminate duplication in the following methods perhaps by relying on exceptions

      def can_handle_observation_request?(observation_request)
        observation_request = observation_request.to_s
        if observation_request.start_with?('on_event_')
          constant_name = observation_request.sub(/^on_event_/, '')
          SWTProxy.has_constant?(constant_name)
        elsif observation_request.start_with?('on_')
          event = observation_request.sub(/^on_/, '')
          can_add_listener?(event)
        else
          false
        end
      end

      def handle_observation_request(observation_request, &block)
        if observation_request.start_with?('on_event_')
          constant_name = observation_request.sub(/^on_event_/, '')
          add_swt_event_listener(constant_name, &block)
        elsif observation_request.start_with?('on_')
          event = observation_request.sub(/^on_/, '')
          add_listener(event, &block)
        end
      end

      def content(&block)
        Glimmer::DSL::Engine.add_content(self, DSL::WidgetExpression.new, &block)
      end

      private

      def style(underscored_widget_name, styles)
        styles = [styles].flatten.compact
        styles.empty? ? default_style(underscored_widget_name) : SWTProxy[*styles]
      end

      def default_style(underscored_widget_name)
        styles = DEFAULT_STYLES[underscored_widget_name] || [:none]
        SWTProxy[styles]
      end

      def attribute_setter(attribute_name)
        "set#{attribute_name.to_s.camelcase(:upper)}"
      end

      def attribute_getter(attribute_name)
        "get#{attribute_name.to_s.camelcase(:upper)}"
      end

      # TODO refactor following methods to eliminate duplication
      # perhaps consider relying on raising an exception to avoid checking first
      # unless that gives obscure SWT errors
      # Otherwise, consider caching results from can_add_lsitener and using them in
      # add_listener knowing it will be called for sure afterwards

      def can_add_listener?(underscored_listener_name)
        !self.class.find_listener(@swt_widget.getClass, underscored_listener_name).empty?
      end

      def add_listener(underscored_listener_name, &block)
        widget_add_listener_method, listener_class, listener_method = self.class.find_listener(@swt_widget.getClass, underscored_listener_name)
        listener = listener_class.new(listener_method.getName => block)
        @swt_widget.send(widget_add_listener_method.getName, listener)
        WidgetListenerProxy.new(listener)
      end

      # Looks through SWT class add***Listener methods till it finds one for which
      # the argument is a listener class that has an event method matching
      # underscored_listener_name
      def self.find_listener(swt_widget_class, underscored_listener_name)
        @listeners ||= {}
        listener_key = [swt_widget_class.name, underscored_listener_name]
        unless @listeners.has_key?(listener_key)
          listener_method_name = underscored_listener_name.camelcase(:lower)
          swt_widget_class.getMethods.each do |widget_add_listener_method|
            if widget_add_listener_method.getName.match(/add.*Listener/)
              widget_add_listener_method.getParameterTypes.each do |listener_type|
                listener_type.getMethods.each do |listener_method|
                  if (listener_method.getName == listener_method_name)
                    @listeners[listener_key] = [widget_add_listener_method, listener_class(listener_type), listener_method]
                    return @listeners[listener_key]
                  end
                end
              end
            end
          end
          @listeners[listener_key] = []
        end
        @listeners[listener_key]
      end

      # Returns a Ruby class that implements listener type Java interface with ability to easily
      # install a block that gets called upon calling a listener event method
      def self.listener_class(listener_type)
        @listener_classes ||= {}
        listener_class_key = listener_type.name
        unless @listener_classes.has_key?(listener_class_key)
          @listener_classes[listener_class_key] = Class.new(Object).tap do |listener_class|
            listener_class.send :include, (eval listener_type.name.sub("interface", ""))
            listener_class.define_method('initialize') do |event_method_block_mapping|
              @event_method_block_mapping = event_method_block_mapping
            end
            listener_type.getMethods.each do |event_method|
              listener_class.define_method(event_method.getName) do |event|
                @event_method_block_mapping[event_method.getName]&.call(event)
              end
            end
          end
        end
        @listener_classes[listener_class_key]
      end

      def add_swt_event_listener(swt_constant, &block)
        event_type = SWTProxy[swt_constant]
        @swt_widget.addListener(event_type, &block)
        WidgetListenerProxy.new(@swt_widget.getListeners(event_type).last)
      end

      def widget_custom_attribute_mapping
        @swt_widget_custom_attribute_mapping ||= {
          'focus' => {
            getter: {name: 'isFocusControl'},
            setter: {name: 'setFocus', invoker: lambda { |widget, args| @swt_widget.setFocus if args.first }},
          }
        }
      end

      def apply_property_type_converters(attribute_name, args)
        if args.count == 1
          value = args.first
          converter = property_type_converters[attribute_name.to_sym]
          args[0] = converter.call(value) if converter
        end
        if args.count == 1 && args.first.is_a?(ColorProxy)
          g_color = args.first
          args[0] = g_color.swt_color
        end
      end

      def property_type_converters
        color_converter = proc do |value|
          if value.is_a?(Symbol) || value.is_a?(String)
            ColorProxy.new(value).swt_color
          else
            value
          end
        end
        @property_type_converters ||= {
          :background => color_converter,
          :background_image => proc do |value|
            if value.is_a?(String)
              image_data = ImageData.new(value)
              # TODO in the future, look into unregistering this listener when no longer needed
              on_event_Resize do |resize_event|
                new_image_data = image_data.scaledTo(@swt_widget.getSize.x, @swt_widget.getSize.y)
                @swt_widget.getBackgroundImage&.dispose
                @swt_widget.setBackgroundImage(Image.new(@swt_widget.getDisplay, new_image_data))
              end
              Image.new(@swt_widget.getDisplay, image_data)
            else
              value
            end
          end,
          :foreground => color_converter,
          :font => proc do |value|
            if value.is_a?(Hash)
              font_properties = value
              FontProxy.new(self, font_properties).swt_font
            else
              value
            end
          end,
          :items => proc do |value|
            value.to_java :string
          end,
          :text => proc do |value|
            value.to_s
          end,
          :visible => proc do |value|
            !!value
          end,
        }
      end
    end
  end
end
