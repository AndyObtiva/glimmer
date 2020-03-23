require_relative 'g_widget'
require_relative 'g_display'

module Glimmer
  class GShell < GWidget
    WIDTH_MIN = 130
    HEIGHT_MIN = 0

    include_package 'org.eclipse.swt.layout'
    include_package 'org.eclipse.swt.widgets'

    attr_reader :display

    # Instantiates shell with same arguments expected by SWT Shell
    def initialize(*args)
      if !args.first.is_a?(Display) && !args.first.is_a?(Shell)
        @display = GDisplay.instance.display
        args = [@display] + args
      end
      args = GSWT.constantify_args(args)
      @widget = Shell.new(*args)
      @display ||= @widget.getDisplay
      @widget.setLayout(FillLayout.new)
      @widget.setMinimumSize(WIDTH_MIN, HEIGHT_MIN)
    end

    # Centers shell within screen
    def center
      primary_monitor = @display.getPrimaryMonitor()
      monitor_bounds = primary_monitor.getBounds()
      shell_bounds = @widget.getBounds()
      location_x = monitor_bounds.x + (monitor_bounds.width - shell_bounds.width) / 2
      location_y = monitor_bounds.y + (monitor_bounds.height - shell_bounds.height) / 2
      @widget.setLocation(location_x, location_y)
    end

    # Opens shell and starts SWT's UI thread event loop
    def open
      @widget.pack
      center
      @widget.open
      until @widget.isDisposed
        @display.sleep unless @display.readAndDispatch
      end
      @display.dispose
    end

  end
end
