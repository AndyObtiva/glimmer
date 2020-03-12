class RColor
  attr_reader :display, :red, :green, :blue, :alpha

  include_package 'org.eclipse.swt.graphics'

  class << self
    include_package 'org.eclipse.swt'

    def for(display, standard_color)
      standard_color_swt_constant = SWT.const_get(standard_color.to_s.upcase.to_sym)
      display.getSystemColor(standard_color_swt_constant)
    end
  end

  def initialize(display, red, green, blue, alpha = nil)
    @display = display
    @red = red
    @green = green
    @blue = blue
    @alpha = alpha
  end

  def color
    @color ||= Color.new(@display, *[@red, @green, @blue, @alpha].compact)
  end

  def display=(a_display)
    @display = a_display
    @color = nil
  end
end
