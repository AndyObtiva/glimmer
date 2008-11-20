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

require "test/unit"
require File.dirname(__FILE__) + "/../src/swt"

class GlimmerTest < Test::Unit::TestCase
	include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'
	include_package 'org.eclipse.swt.graphics'
		
	def teardown
		@target.display.dispose if @target.display
	end
	
  def test_shell_with_default_layout
    @target = shell
    
    assert_not_nil @target
    assert_not_nil @target.widget
    assert_instance_of Shell, @target.widget
    assert_not_nil @target.widget.getLayout
    assert_instance_of FillLayout, @target.widget.getLayout
  end
  
  def test_shell_with_title_and_layout
    shell_layout = GridLayout.new
    @target = shell {
      text "Title"
      layout shell_layout
    }
    
    assert_equal "Title", @target.widget.getText
    assert_equal shell_layout, @target.widget.getLayout
  end
  
  def test_shell_with_bounds
    @target = shell {
      bounds 50, 75, 800, 600
    }
    
    assert_equal Rectangle.new(50, 75, 800, 600), @target.widget.getBounds
  end
  
  def test_shell_with_size
    GlimmerTest.class_eval("undef_method :size") #hack to remove existing size method in test class
    
    @target = shell {
      size 800, 600
    }
    
    assert_equal Point.new(800, 600), @target.widget.getSize
  end
  
  def test_shell_and_composite_with_default_style_and_layout
    @target = shell {
      composite
    }
    
    assert_equal 1, @target.widget.children.size
    assert_instance_of Composite, @target.widget.children[0]
    composite_widget = @target.widget.children[0]
    assert_has_style SWT::NONE, composite_widget
    assert_instance_of GridLayout, composite_widget.getLayout
    grid_layout = composite_widget.getLayout
    assert_equal 1, grid_layout.numColumns
    assert_equal false, grid_layout.makeColumnsEqualWidth
  end
  
  def test_shell_and_group_with_default_style_and_layout
    @target = shell {
      group {
        text "Title"
      }
    }
    
    assert_equal 1, @target.widget.children.size
    assert_instance_of Group, @target.widget.children[0]
    group_widget = @target.widget.children[0]
    assert_has_style SWT::NONE, group_widget
    assert_instance_of GridLayout, group_widget.getLayout
    grid_layout = group_widget.getLayout
    assert_equal 1, grid_layout.numColumns
    assert_equal false, grid_layout.makeColumnsEqualWidth
    assert_equal "Title", group_widget.getText
  end
  
  def test_shell_and_composite_with_style_and_layout
    composite_layout = RowLayout.new
    @target = shell {
      composite(SWT::NO_FOCUS) {
        layout composite_layout
      }
    }
    
    assert_equal 1, @target.widget.children.size
    assert_instance_of Composite, @target.widget.children[0]
    composite_widget = @target.widget.children[0]
    assert_has_style SWT::NO_FOCUS, composite_widget
    assert_equal composite_layout, composite_widget.getLayout
  end
  
  def test_shell_and_composite_and_text_with_default_style
    @target = shell {
      composite {
        text
      }
    }
    
    composite_widget = @target.widget.children[0]
    assert_equal 1, composite_widget.children.size
    assert_instance_of Text, composite_widget.children[0]
    text_widget = composite_widget.children[0]
    assert_has_style SWT::BORDER, text_widget
  end
  
  def test_shell_and_composite_with_custom_layout_and_text_with_default_style
    composite_layout = RowLayout.new
    @target = shell {
      composite {
        text
        layout composite_layout
      }
    }
    
    composite_widget = @target.widget.children[0]
    assert_equal composite_layout, composite_widget.getLayout
    assert_equal 1, composite_widget.children.size
    assert_instance_of Text, composite_widget.children[0]
    text_widget = composite_widget.children[0]
    assert_has_style SWT::BORDER, text_widget
  end
  
  def test_shell_and_composite_and_text_with_style_and_text
    @target = shell {
      composite {
        text(SWT::PASSWORD) {
          text "Hello"
        }
      }
    }
    
    composite_widget = @target.widget.children[0]
    assert_equal 1, composite_widget.children.size
    assert_instance_of Text, composite_widget.children[0]
    text_widget = composite_widget.children[0]
    assert_has_style SWT::PASSWORD, text_widget
    assert_equal "Hello", text_widget.getText
  end
    
  def test_shell_and_spinner_default
    @target = shell {
      @spinner = spinner {
        selection 55
      }
    }
    
    assert_instance_of Spinner, @spinner.widget
    assert_has_style SWT::BORDER, @spinner.widget
    assert_equal 55, @spinner.widget.getSelection
  end
    
  def test_shell_and_button_default
    @target = shell {
      @button = button {
        text "Push Me"
      }
    }
    
    assert_instance_of Button, @button.widget
    assert_has_style SWT::PUSH, @button.widget
    assert_equal "Push Me", @button.widget.text
  end
    
  def test_shell_and_table_and_table_column_defaults
    @target = shell {
      @table = table {
        @table_column = table_column
      }
    }

    assert_has_style SWT::BORDER, @table.widget
    assert @table.widget.getHeaderVisible
    assert @table.widget.getLinesVisible
    assert_equal 80, @table_column.widget.getWidth
  end
    
  def test_shell_containing_undefined_command
    @target = shell {
      undefined_command(:undefined_parameter) { 
      }
    }
    
    assert_not_nil @target
    assert_not_nil @target.widget
    assert_instance_of Shell, @target.widget
    assert_not_nil @target.widget.getLayout
    assert_instance_of FillLayout, @target.widget.getLayout
  end
  
    
  def test_add_contents
    @target = shell {
    }
    
    add_contents(@target) {
      composite {
        text(SWT::PASSWORD) {
          text "Hello"
        }
      }
    }
    
    composite_widget = @target.widget.children[0]
    assert_equal 1, composite_widget.children.size
    assert_instance_of Text, composite_widget.children[0]
    text_widget = composite_widget.children[0]
    assert_has_style SWT::PASSWORD, text_widget
    assert_equal "Hello", text_widget.getText
  end
  
  private
  
  def assert_has_style(style, widget)
    assert_equal style, widget.getStyle & style
  end
  
  
end

