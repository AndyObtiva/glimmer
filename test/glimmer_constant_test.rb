require File.dirname(__FILE__) + "/helper"

class GlimmerTest < Test::Unit::TestCase
  include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'
  
  def setup
    dsl :swt
  end

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

