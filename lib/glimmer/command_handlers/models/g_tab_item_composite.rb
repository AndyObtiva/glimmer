require File.dirname(__FILE__) + "/g_widget_listener"
require File.dirname(__FILE__) + "/g_runnable"

class GTabItemComposite < GWidget
  include_package 'org.eclipse.swt.widgets'
  
  attr_reader :tab_item
  def initialize(tab_item, parent, style, &contents)
    super("composite", parent, style, &contents)
    @tab_item = tab_item
    @tab_item.widget.control = self.widget
  end
  
  def has_attribute?(attribute_name, *args)
    if attribute_name.to_s == "text"
      true
    else
      super(attribute_name, *args)
    end
  end

  def set_attribute(attribute_name, *args)
    if attribute_name.to_s == "text"
      text_value = args[0]
      @tab_item.widget.text = text_value
    else
      super(attribute_name, *args)
    end
  end

end