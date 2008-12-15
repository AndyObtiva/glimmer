require "test/unit"
require File.dirname(__FILE__) + "/../lib/swt"  

module TestHelper

protected
  # Add custom assert methods here and include TestHelper in your TestCase
  
  def assert_has_style(style, widget)
    assert_equal style, widget.getStyle & style
  end
end