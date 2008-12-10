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

require File.dirname(__FILE__) + "/r_widget"

class RShell < RWidget
  include_package 'org.eclipse.swt.layout'
  include_package 'org.eclipse.swt.widgets'
  
  attr_reader :display
  
  def initialize(display = Display.new)
    @display = display
    @widget = Shell.new(@display)
    @widget.setLayout(FillLayout.new)
  end
  
  def open
    @widget.pack
    @widget.open
    until @widget.isDisposed
      @display.sleep unless @display.readAndDispatch
    end
    @display.dispose
  end
  
end