require 'glimmer/swt/widget_listener_proxy'
require 'glimmer/swt/runnable_proxy'
require 'glimmer/swt/color_proxy'
require 'glimmer/swt/font_proxy'
require 'glimmer/swt/swt_proxy'

module Glimmer
  module SWT
    class WidgetProxy
      include Glimmer # TODO consider removing when no longer needed
      include ObservableWidget

      include_package 'org.eclipse.swt'
      include_package 'org.eclipse.swt.widgets'
      include_package 'org.eclipse.swt.layout'
      include_package 'org.eclipse.swt.graphics'
      include_package 'org.eclipse.swt.browser'

      attr_reader :widget

      #TODO externalize
      @@default_styles = {
        "text" => GSWT[:border],
        "table" => GSWT[:border],
        "spinner" => GSWT[:border],
        "list" => GSWT[:border, :v_scroll],
        "button" => GSWT[:push],
      }

      #TODO externalize
      @@default_initializers = {
        "composite" => Proc.new {|composite| composite.setLayout(GridLayout.new) },
        "table" => Proc.new do |table|
          table.setHeaderVisible(true)
          table.setLinesVisible(true)
        end,
        "table_column" => Proc.new { |table_column| table_column.setWidth(80) },
        "group" => Proc.new {|group| group.setLayout(GridLayout.new) },
      }

      #styles is a comma separate list of symbols representing SWT styles in lower case
      def initialize(underscored_widget_name, parent, styles, &contents)
        @widget = self.class.swt_widget_class_for(underscored_widget_name).new(parent, style(underscored_widget_name, styles))
        @@default_initializers[underscored_widget_name].call(@widget) if @@default_initializers[underscored_widget_name]
      end

      def widget_custom_attribute_mapping
        @widget_custom_attribute_mapping ||= {
          'focus' => {
            getter: {name: 'isFocusControl'},
            setter: {name: 'setFocus', invoker: lambda { |widget, args| widget.setFocus if args.first }},
          }
        }
      end

      def has_attribute?(attribute_name, *args)
        widget_custom_attribute = widget_custom_attribute_mapping[attribute_name.to_s]
        if widget_custom_attribute
          @widget.respond_to?(widget_custom_attribute[:setter][:name])
        else
          @widget.respond_to?(attribute_setter(attribute_name), args)
        end
      end

      def set_attribute(attribute_name, *args)
        widget_custom_attribute = widget_custom_attribute_mapping[attribute_name.to_s]
        if widget_custom_attribute
          widget_custom_attribute[:setter][:invoker].call(@widget, args)
        else
          apply_property_type_converters(attribute_name, args)
          @widget.send(attribute_setter(attribute_name), *args)
        end
      end

      def get_attribute(attribute_name)
        widget_custom_attribute = widget_custom_attribute_mapping[attribute_name.to_s]
        if widget_custom_attribute
          @widget.send(widget_custom_attribute[:getter][:name])
        else
          @widget.send(attribute_getter(attribute_name))
        end
      end

      def property_type_converters
        color_converter = Proc.new do |value|
          if value.is_a?(Symbol) || value.is_a?(String)
            GColor.color_for(widget.getDisplay, value)
          else
            value
          end
        end
        @property_type_converters ||= {
          :text => Proc.new { |value| value.to_s },
          :items => Proc.new { |value| value.to_java :string},
          :visible => Proc.new { |value| !!value},
          :background => color_converter,
          :background_image => Proc.new do |value|
            if value.is_a?(String)
              image_data = ImageData.new(value)
              # TODO in the future, look into unregistering this listener when no longer needed
              on_event_Resize do |resize_event|
                new_image_data = image_data.scaledTo(widget.getSize.x, widget.getSize.y)
                widget.getBackgroundImage&.dispose
                widget.setBackgroundImage(Image.new(widget.getDisplay, new_image_data))
              end
              Image.new(widget.getDisplay, image_data)
            else
              value
            end
          end,
          :foreground => color_converter,
          :font => Proc.new do |value|
            if value.is_a?(Hash)
              font_properties = value
              FontProxy.new(self, font_properties).swt_font
            else
              value
            end
          end,
        }
      end

      def widget_property_listener_installers
        @widget_property_listener_installers ||= {
          Java::OrgEclipseSwtWidgets::Control => {
            :focus => Proc.new do |observer|
              on_focus_gained { |focus_event|
                observer.call(true)
              }
              on_focus_lost { |focus_event|
                observer.call(false)
              }
            end,
          },
          Java::OrgEclipseSwtWidgets::Text => {
            :text => Proc.new do |observer|
              on_modify_text { |modify_event|
                observer.call(widget.getText)
              }
            end,
          },
          Java::OrgEclipseSwtWidgets::Button => {
            :selection => Proc.new do |observer|
              on_widget_selected { |selection_event|
                observer.call(widget.getSelection)
              }
            end
          },
          Java::OrgEclipseSwtWidgets::Spinner => {
            :selection => Proc.new do |observer|
              on_widget_selected { |selection_event|
                observer.call(widget.getSelection)
              }
            end
          }
        }
      end

      def apply_property_type_converters(attribute_name, args)
        if args.count == 1
          value = args.first
          converter = property_type_converters[attribute_name.to_sym]
          args[0] = converter.call(value) if converter
        end
        if args.count == 1 && args.first.is_a?(GColor)
          g_color = args.first
          g_color.display = widget.display if g_color.display.nil? || g_color.display != widget.display
          args[0] = g_color.color
        end
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
        Glimmer.logger.debug("#{e.message}\n#{e.backtrace.join("\n")}")
        nil
      rescue => e
        Glimmer.logger.debug("#{e.message}\n#{e.backtrace.join("\n")}")
        nil
      end

      # TODO refactor following methods to eliminate duplication
      # perhaps consider relying on raising an exception to avoid checking first
      # unless that gives obscure SWT errors
      # Otherwise, consider caching results from can_add_lsitener and using them in
      # add_listener knowing it will be called for sure afterwards

      def can_add_listener?(underscored_listener_name)
        listener_method_name = underscored_listener_name.camelcase(:lower)
        @widget.getClass.getMethods.each do |widget_method|
          if widget_method.getName.match(/add.*Listener/)
            widget_method.getParameterTypes.each do |listener_type|
              listener_type.getMethods.each do |listener_method|
                if (listener_method.getName == listener_method_name)
                  return true
                end
              end
            end
          end
        end
        return false
      end

      def add_listener(underscored_listener_name, &block)
        listener_method_name = underscored_listener_name.camelcase(:lower)
        @widget.getClass.getMethods.each do |widget_method|
          if widget_method.getName.match(/add.*Listener/)
            widget_method.getParameterTypes.each do |listener_type|
              listener_type.getMethods.each do |listener_method|
                if (listener_method.getName == listener_method_name)
                  listener_class = Class.new(Object)
                  listener_class.send :include, (eval listener_type.to_s.sub("interface", ""))
                  listener = listener_class.new
                  listener_type.getMethods.each do |t_method|
                    # TODO consider define_method instead
                    eval "def listener.#{t_method.getName}(event) end"
                  end
                  def listener.block=(block)
                    @block = block
                  end
                  listener.block=block
                  # TODO consider define_method instead
                  eval "def listener.#{listener_method.getName}(event) @block.call(event) if @block end"
                  @widget.send(widget_method.getName, listener)
                  return GWidgetListener.new(listener)
                end
              end
            end
          end
        end
      end

      def async_exec(&block)
        GDisplay.instance.async_exec(&block)
      end

      def sync_exec(&block)
        GDisplay.instance.sync_exec(&block)
      end

      def has_style?(style)
        (widget.style & GSWT[style]) == GSWT[style]
      end

      def dispose
        @widget.dispose
      end

      # TODO Consider renaming these methods as they are mainly used for data-binding

      def can_add_observer?(property_name)
        @widget.class.ancestors.map {|ancestor| widget_property_listener_installers[ancestor]}.compact.map(&:keys).flatten.map(&:to_s).include?(property_name.to_s)
      end

      def add_observer(observer, property_name)
        property_listener_installers = @widget.class.ancestors.map {|ancestor| widget_property_listener_installers[ancestor]}.compact
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
          GSWT.has_constant?(constant_name)
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
          @widget.addListener(GSWT[constant_name], &block)
        elsif observation_request.start_with?('on_')
          event = observation_request.sub(/^on_/, '')
          add_listener(event, &block)
        end
        nil
      end

      def content(&block)
        Glimmer::DSL::Engine.add_content(self, &block)
      end

      private

      def style(underscored_widget_name, styles)
        styles.empty? ? default_style(underscored_widget_name) : GSWT[*styles]
      end

      def default_style(underscored_widget_name)
        style = @@default_styles[underscored_widget_name] if @@default_styles[underscored_widget_name]
        style = GSWT[:none] unless style
        style
      end

      def attribute_setter(attribute_name)
        "set#{attribute_name.to_s.camelcase(:upper)}"
      end

      def attribute_getter(attribute_name)
        "get#{attribute_name.to_s.camelcase(:upper)}"
      end
    end
  end
end
