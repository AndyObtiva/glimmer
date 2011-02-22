################################################################################
# Copyright (c) 2008 Annas Al Maleh.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#    Annas Al Maleh - initial API and implementation
################################################################################ 

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
  
  def initialize(underscored_widget_name, parent, style, &contents)
    style = default_style(underscored_widget_name) unless style
    @widget = eval underscored_widget_name.to_s.camelcase + '.new(parent, style)'
    @@default_initializers[underscored_widget_name].call(@widget) if @@default_initializers[underscored_widget_name]
  end
  
  def default_style(underscored_widget_name)
    style = @@default_styles[underscored_widget_name] if @@default_styles[underscored_widget_name]
    style = SWT::NONE unless style
    style
  end
  
  def respond_to?(method_symbol, *args)
    @widget.respond_to?("set#{method_symbol.to_s.camelcase(:upper)}", args)
  end
  
  def method_missing(method_symbol, *args)
    statement_to_eval = "@widget.send('set' + method_symbol.to_s.camelcase(:upper)"
    statement_to_eval << expand_arguments(args)
    statement_to_eval << ")"
    eval statement_to_eval
  end
  
  def expand_arguments(args)
    expanded_args = ""
    index = 0
    args.each do
      expanded_args << ", args[#{index}]"
      index += 1
    end
    expanded_args
  end
  
  def self.widget_exists?(underscored_widget_name)
    begin
      eval underscored_widget_name.camelcase
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
    (widget.style & style) == style
  end
  
end