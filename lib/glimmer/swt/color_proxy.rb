require 'glimmer/swt/swt_proxy'
require 'glimmer/swt/display_proxy'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.graphics.Color
    #
    # Invoking `#swt_color` returns the SWT color object wrapped by this proxy
    #
    # Follows the Proxy Design Pattern
    class ColorProxy
      include_package 'org.eclipse.swt.graphics'

      attr_reader :swt_color

      # Initializes a proxy for an SWT Color object
      #
      # Takes a standard color single argument, rgba 3 args, or rgba 4 args
      #
      # A standard color is a string/symbol representing one of the
      # SWT.COLOR_*** constants like SWT.COLOR_RED, but in underscored string
      # format (e.g :color_red).
      # Glimmer can also accept standard color names without the color_ prefix,
      # and it will automatically figure out the SWT.COLOR_*** constant
      # (e.g. :red)
      #
      # rgb is 3 arguments representing Red, Green, Blue numeric values
      #
      # rgba is 4 arguments representing Red, Green, Blue, and Alpha numeric values
      #
      def initialize(*args)
        case args.size
        when 1
          if args.first.is_a?(String) || args.first.is_a?(Symbol)
            standard_color = args.first
            standard_color = "color_#{standard_color}".to_sym unless standard_color.to_s.downcase.include?('color_')
            @swt_color = DisplayProxy.instance.swt_display.getSystemColor(SWTProxy[standard_color])
          else
            @swt_color = args.first
          end
        when 3..4
          red, green, blue, alpha = args
          @swt_color = Color.new(DisplayProxy.instance.swt_display, *[red, green, blue, alpha].compact)
        end
      end
    end
  end
end
