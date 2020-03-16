require_relative 'g_swt'

module Glimmer
  class GColor
    attr_reader :display, :red, :green, :blue, :alpha

    include_package 'org.eclipse.swt.graphics'

    class << self
      include_package 'org.eclipse.swt'

      def for(display, standard_color)
        display.getSystemColor(GSWT[standard_color])
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
end
