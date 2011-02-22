require File.dirname(__FILE__) + "/helper"

class GlimmerTest < Test::Unit::TestCase
  include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'
	include_package 'org.eclipse.swt.graphics'
		
  def setup
    dsl :swt
  end

	def teardown
		@target.display.dispose if @target.display
	end
	
  def test_tab_item_composite_with_default_layout
    @target = shell {
      @tab_folder = tab_folder {
        @tab_item_composite = tab_item {
          text "Tab 1"
          label {text "Hello"}
        }
      }
    }
    
    assert_not_nil @target
    assert_not_nil @target.widget
    assert_equal 1, @tab_folder.widget.items.size
    assert_instance_of Composite, @tab_item_composite.widget
    assert_equal @tab_item_composite.widget, @tab_folder.widget.items[0].control
    assert_equal "Tab 1", @tab_item_composite.tab_item.widget.text
    assert_not_nil @tab_item_composite.widget.getLayout
    assert_instance_of GridLayout, @tab_item_composite.widget.getLayout
  end
  
  def test_tab_item_composite_with_fill_layout
    @target = shell {
      @tab_folder = tab_folder {
        @tab_item_composite = tab_item {
          text "Tab 2"
          layout FillLayout.new
          label {text "Hello"}
        }
      }
    }
    
    assert_not_nil @target
    assert_not_nil @target.widget
    assert_equal 1, @tab_folder.widget.items.size
    assert_instance_of Composite, @tab_item_composite.widget
    assert_equal @tab_item_composite.widget, @tab_folder.widget.items[0].control
    assert_equal "Tab 2", @tab_item_composite.tab_item.widget.text
    assert_not_nil @tab_item_composite.widget.getLayout
    assert_instance_of FillLayout, @tab_item_composite.widget.getLayout
  end
  
end

