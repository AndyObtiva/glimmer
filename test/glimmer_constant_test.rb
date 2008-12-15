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

require File.dirname(__FILE__) + "/test_helper"

class GlimmerTest < Test::Unit::TestCase
	include Glimmer
  include TestHelper
  
	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'
  
	def teardown
		@target.display.dispose if @target.display
	end
	
  def test_shell_with_default_layout
    @target = shell {
      composite(border | no_focus) {
      }
    }
    
    assert_equal 1, @target.widget.children.size
    assert_instance_of Composite, @target.widget.children[0]
    composite_widget = @target.widget.children[0]
    assert_has_style SWT::NO_FOCUS, composite_widget
    assert_has_style SWT::BORDER, composite_widget
  end
end

