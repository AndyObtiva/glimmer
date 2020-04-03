require_relative 'g_widget_listener'
require_relative 'g_runnable'
require_relative 'g_color'
require_relative 'g_font'
require_relative 'g_swt'
require_relative '../parent'

module Glimmer
  module SWT
    class GWidget
      include_package 'org.eclipse.swt'
      include_package 'org.eclipse.swt.widgets'
      include_package 'org.eclipse.swt.layout'
      include_package 'org.eclipse.swt.graphics'
      include_package 'org.eclipse.swt.browser'

      include Glimmer # TODO consider removing when no longer needed
      include Parent

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

      def has_attribute?(attribute_name, *args)
        @widget.respond_to?(attribute_setter(attribute_name), args)
      end

      def set_attribute(attribute_name, *args)
        apply_property_type_converters(attribute_name, args)
        @widget.send(attribute_setter(attribute_name), *args)
      end

      def get_attribute(attribute_name)
        @widget.send(attribute_getter(attribute_name))
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
          :foreground => color_converter,
          :font => Proc.new do |value|
            if value.is_a?(Hash)
              font_properties = value
              GFont.for(self).font(font_properties)
            else
              value
            end
          end,
        }
      end

      def widget_property_listener_installers
        @widget_property_listener_installers ||= {
          Java::OrgEclipseSwtWidgets::Text => {
            :text => Proc.new do |observer|
              add_contents(self) {
                on_modify_text { |modify_event|
                  observer.call(widget.getText)
                }
              }
            end,
          },
          Java::OrgEclipseSwtWidgets::Button => {
            :selection => Proc.new do |observer|
              add_contents(self) {
                on_widget_selected { |selection_event|
                  observer.call(widget.getSelection)
                }
              }
            end
          },
          Java::OrgEclipseSwtWidgets::Spinner => {
            :selection => Proc.new do |observer|
              add_contents(self) {
                on_widget_selected { |selection_event|
                  observer.call(widget.getSelection)
                }
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
                    eval "def listener.#{t_method.getName}(event) end"
                  end
                  def listener.block=(block)
                    @block = block
                  end
                  listener.block=block
                  eval "def listener.#{listener_method.getName}(event) @block.call(event) if @block end"
                  @widget.send(widget_method.getName, listener)
                  return GWidgetListener.new(listener)
                end
              end
            end
          end
        end
      end

      def process_block(block)
        block.call(@widget)
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
        widget_property_listener_installers[@widget.class].values.map(&:keys).flatten.map(&:to_s).include?(property_name.to_s)
      end

      def add_observer(observer, property_name)
        property_listener_installers = widget_property_listener_installers[@widget.class]
        widget_listener_installer = property_listener_installers[property_name.to_s.to_sym] if property_listener_installers
        widget_listener_installer.call(observer) if widget_listener_installer
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

      def method_missing(method, *args, &block)
        method_name = method.to_s
        if can_handle_observation_request?(method_name)
          handle_observation_request(method_name, &block)
        else
          super
        end
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
