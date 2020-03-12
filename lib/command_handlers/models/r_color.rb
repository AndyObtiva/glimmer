class RColor
  attr_reader :display
  attr_reader :color

  include_package 'org.eclipse.swt.graphics'

  class << self
    def for(display, standard_color)
      standard_color_swt_constant = org.eclipse.swt.SWT.const_get(standard_color.to_s.upcase.to_sym)
      display.getSystemColor(standard_color_swt_constant)
    end
  end

  def initialize(display, red, green, blue, alpha = nil)
    @display = display
    @color = Color.new(@display, *[red, green, blue, alpha].compact)
  end
end
