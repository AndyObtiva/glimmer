require_relative 'g_widget'
require_relative 'g_display'

module Glimmer
  module SWT
    class GShell < GWidget
      WIDTH_MIN = 130
      HEIGHT_MIN = 0

      include_package 'org.eclipse.swt.layout'
      include_package 'org.eclipse.swt.widgets'

      attr_reader :display, :opened_before
      alias opened_before? opened_before

      # Instantiates shell with same arguments expected by SWT Shell
      def initialize(*args)
        if args.first.nil? || !args.first.is_a?(Display) && !args.first.is_a?(Shell)
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
        if @opened_before
          @widget.setVisible(true)
          # notify_observers('visible')
        else
          @opened_before = true
          @widget.pack
          center
          @widget.open
          # NOTE: the following line runs after scheduled sync exec events,
          # but ensures visible status is only updated upon true visibility
          # async_exec do
            # notify_observers('visible')
          # end
          start_event_loop
          @display.dispose # it's more performant to reuse instead of disposing
        end
      end
      alias show open

      def hide
        @widget.setVisible(false)
        # notify_observers('visible')
      end

      def close
        @widget.close
        # notify_observers('visible')
      end

      # TODO implement and notify_observers('visible') based on open and hide

      def visible?
        @widget.isDisposed ? false : @widget.isVisible
      end

      # TODO evaluate if this is needed

      def visible=(visibility)
        visibility ? show : hide
      end

      def start_event_loop
        until @widget.isDisposed
          @display.sleep unless @display.readAndDispatch
        end
      end

      def add_observer(observer, property_name)
        case property_name.to_s
        when 'visible?'
          @widget.addListener(GSWT[:show]) do |event|
            observer.call(visible?)
          end
          @widget.addListener(GSWT[:hide]) do |event|
            observer.call(visible?)
          end
          @widget.addListener(GSWT[:close]) do |event|
            observer.call(visible?)
          end
        else
          super
        end
      end
    end
  end
end
