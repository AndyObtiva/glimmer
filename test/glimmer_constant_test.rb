require_relative "helper"

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

  def test_shell_with_default_layout_and_composite
    @target = shell {
      composite(:border, :no_focus) {
      }
    }

    assert_equal 1, @target.widget.children.size
    assert_instance_of Composite, @target.widget.children[0]
    composite_widget = @target.widget.children[0]
    assert_has_style :no_focus, composite_widget
    assert_has_style :border, composite_widget
  end
end
