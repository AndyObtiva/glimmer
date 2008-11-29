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

class RTabItemComposite < RWidget
  include_package 'org.eclipse.swt.widgets'
  
  attr_reader :tab_item
  def initialize(tab_item, parent, style, &contents)
    super("composite", parent, style, &contents)
    @tab_item = tab_item
    @tab_item.widget.control = self.widget
  end
  
  def respond_to?(method_symbol, *args)
    if method_symbol.to_s == "text"
      true
    else
      super(method_symbol, *args)
    end
  end

  def text(text_value)
    @tab_item.widget.text=text_value
  end
end