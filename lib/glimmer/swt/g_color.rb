require_relative 'g_swt'
require_relative 'g_display'

module Glimmer
  module SWT
    class GColor
      attr_reader :display, :red, :green, :blue, :alpha

      include_package 'org.eclipse.swt.graphics'

      class << self
        include_package 'org.eclipse.swt'

        # TODO consider refactoring to simply for and returning GColor instead for consistency

        def color_for(display = nil, standard_color)
          standard_color = "color_#{standard_color}".to_sym unless standard_color.to_s.include?('color_')
          display ||= GDisplay.instance.display
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
end
