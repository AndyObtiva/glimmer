require_relative 'g_widget_listener'
require_relative 'g_runnable'
require_relative 'g_color'
require_relative 'g_font'
require_relative 'g_swt'
require_relative '../../parent'

module Glimmer
  class GWidget
    include_package 'org.eclipse.swt'
    include_package 'org.eclipse.swt.widgets'
    include_package 'org.eclipse.swt.layout'
    include_package 'org.eclipse.swt.graphics'
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

    def property_type_converters
      @property_type_converters ||= {
        :text => Proc.new { |value| value.to_s },
        :items => Proc.new { |value| value.to_java :string},
        :visible => Proc.new { |value| !!value},
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

    def apply_property_type_converters(attribute_name, args)
      if args.count == 1
        value = args.first
        converter = property_type_converters[attribute_name.to_sym]
        args[0] = converter.call(value) if converter
      end
      if args.count == 1 && (args.first.is_a?(Symbol) || args.first.is_a?(String)) && args.first.to_s.start_with?('color_')
        standard_color = args.first
        args[0] = GColor.for(widget.getDisplay, standard_color)
      elsif args.count == 1 && args.first.is_a?(GColor)
        g_color = args.first
        g_color.display = widget.display if g_color.display.nil? || g_color.display != widget.display
        args[0] = g_color.color
      end
    end

    def self.widget_exists?(underscored_widget_name)
      begin
        swt_widget_class_for(underscored_widget_name)
        true
      rescue NameError
        false
      end
    end

    # This supports widgets in and out of basic SWT
    def self.swt_widget_class_for(underscored_widget_name)
      swt_widget_name = underscored_widget_name.camelcase(:upper)
      swt_widget_class = eval(swt_widget_name)
      unless swt_widget_class.ancestors.include?(org.eclipse.swt.widgets.Widget)
        raise NameError, "Class #{swt_widget_class} matching #{underscored_widget_name} is not a subclass of org.eclipse.swt.widgets.Widget"
      end
      swt_widget_class
    end

    def widget_listener_exists?(underscored_listener_name)
      listener_method_name = underscored_listener_name.listener_method_name(:lower)
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
      @widget.getDisplay.asyncExec(GRunnable.new(&block))
    end

    def sync_exec(&block)
      @widget.getDisplay.syncExec(GRunnable.new(&block))
    end

    def has_style?(style)
      (widget.style & GSWT[style]) == GSWT[style]
    end

    def dispose
      @widget.dispose
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

  end
end