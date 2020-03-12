class RColor
  attr_reader :display
  attr_reader :color

  include_package 'org.eclipse.swt.graphics'

  def initialize(display, red, green, blue, alpha = nil)
    @display = display
    @color = Color.new(@display, *[red, green, blue, alpha].compact)
  end
end
