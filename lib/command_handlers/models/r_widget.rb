require File.dirname(__FILE__) + "/r_widget_listener"
require File.dirname(__FILE__) + "/r_runnable"

class RWidget
  require File.dirname(__FILE__) + "/r_widget_packages"

  include Parent

  attr_reader :widget

  #TODO externalize
  @@default_styles = {
    "text" => SWT::BORDER,
    "table" => SWT::BORDER,
    "spinner" => SWT::BORDER,
    "list" => SWT::BORDER | SWT::V_SCROLL,
    "button" => SWT::PUSH,
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
    @widget = underscored_widget_name.swt_widget.new(parent, style(underscored_widget_name, styles))
    @@default_initializers[underscored_widget_name].call(@widget) if @@default_initializers[underscored_widget_name]
  end

  def has_attribute?(attribute_name, *args)
    @widget.respond_to?(attribute_setter(attribute_name), args)
  end

  def set_attribute(attribute_name, *args)
    @widget.send(attribute_setter(attribute_name), *args)
  end

  def self.widget_exists?(underscored_widget_name)
    begin
      eval underscored_widget_name.camelcase(:upper)
      true
    rescue NameError
      false
    end
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
              return RWidgetListener.new(listener)
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
    @widget.getDisplay.asyncExec(RRunnable.new(&block))
  end

  def sync_exec(&block)
    @widget.getDisplay.syncExec(RRunnable.new(&block))
  end

  def has_style?(style)
    (widget.style & style.swt_constant) == style.swt_constant
  end

  private

  def style(underscored_widget_name, styles)
    styles.empty? ? default_style(underscored_widget_name) : swt_style(styles)
  end

  def default_style(underscored_widget_name)
    style = @@default_styles[underscored_widget_name] if @@default_styles[underscored_widget_name]
    style = SWT::NONE unless style
    style
  end

  def swt_style(styles)
    swt_styles(styles).inject(0) { |combined_style, style| combined_style | style }
  end

  def swt_styles(styles)
    styles.map(&:swt_constant)
  end

  def attribute_setter(attribute_name)
    "set#{attribute_name.to_s.camelcase(:upper)}"
  end

end
