require 'glimmer/swt/swt_proxy'
require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/display_proxy'
require 'glimmer/swt/swt_proxy'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.widgets.Shell
    #
    # Follows the Proxy Design Pattern
    class ShellProxy < WidgetProxy
      include_package 'org.eclipse.swt.widgets'
      include_package 'org.eclipse.swt.layout'

      WIDTH_MIN = 130
      HEIGHT_MIN = 0
      OBSERVED_MENU_ITEMS = ['about', 'preferences']

      attr_reader :opened_before
      alias opened_before? opened_before

      # Instantiates ShellProxy with same arguments expected by SWT Shell
      def initialize(*args)
        if args.first.is_a?(ShellProxy)
          args[0] = args[0].swt_widget
        end
        style_args = args.select {|arg| arg.is_a?(Symbol) || arg.is_a?(String)}
        if style_args.any?
          style_arg_start_index = args.index(style_args.first)
          style_arg_last_index = args.index(style_args.last)
          args[style_arg_start_index..style_arg_last_index] = SWTProxy[style_args]
        end
        if args.first.nil? || (!args.first.is_a?(Display) && !args.first.is_a?(Shell))
          @display = DisplayProxy.instance.swt_display
          args = [@display] + args
        end
        args = args.compact
        @swt_widget = Shell.new(*args)
        @display ||= @swt_widget.getDisplay
        @swt_widget.setLayout(FillLayout.new)
        @swt_widget.setMinimumSize(WIDTH_MIN, HEIGHT_MIN)
      end

      # Centers shell within monitor it is in
      def center
        primary_monitor = @display.getPrimaryMonitor()
        monitor_bounds = primary_monitor.getBounds()
        shell_bounds = @swt_widget.getBounds()
        location_x = monitor_bounds.x + (monitor_bounds.width - shell_bounds.width) / 2
        location_y = monitor_bounds.y + (monitor_bounds.height - shell_bounds.height) / 2
        @swt_widget.setLocation(location_x, location_y)
      end

      # Opens shell and starts SWT's UI thread event loop
      def open
        if @opened_before
          @swt_widget.setVisible(true)
          # notify_observers('visible')
        else
          @opened_before = true
          @swt_widget.pack
          center
          @swt_widget.open
          start_event_loop
        end
      end
      alias show open

      def hide
        @swt_widget.setVisible(false)
      end

      def close
        @swt_widget.close
      end

      def visible?
        @swt_widget.isDisposed ? false : @swt_widget.isVisible
      end

      # Setting to true opens/shows shell. Setting to false hides the shell.
      def visible=(visibility)
        visibility ? show : hide
      end

      def pack
        @swt_widget.pack
      end

      def pack_same_size
        minimum_size = @swt_widget.getMinimumSize
        bounds = @swt_widget.getBounds
        @swt_widget.setMinimumSize(bounds.width, bounds.height)
        listener = on_control_resized {
          @swt_widget.setSize(bounds.width, bounds.height)
          @swt_widget.setLocation(bounds.x, bounds.y)
        }
        @swt_widget.pack
        @swt_widget.removeControlListener(listener.swt_listener)
        @swt_widget.setMinimumSize(minimum_size)
      end

      def content(&block)
        Glimmer::DSL::Engine.add_content(self, DSL::ShellExpression.new, &block)
      end

      # (happens as part of `#open`)
      # Starts SWT Event Loop.
      #
      # You may learn more about the SWT Event Loop here:
      # https://help.eclipse.org/2019-12/nftopic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/widgets/Display.html
      # This method is not needed except in rare circumstances where there is a need to start the SWT Event Loop before opening the shell.
      def start_event_loop
        until @swt_widget.isDisposed
          @display.sleep unless @display.readAndDispatch
        end
      end

      def can_handle_observation_request?(observation_request)
        result = false
        if observation_request.start_with?('on_')
          event_name = observation_request.sub(/^on_/, '')
          result = OBSERVED_MENU_ITEMS.include?(event_name)
        end
        result || super
      end

      def handle_observation_request(observation_request, &block)
        if observation_request.start_with?('on_')
          event_name = observation_request.sub(/^on_/, '')
          if OBSERVED_MENU_ITEMS.include?(event_name)
            if OS.mac?
              system_menu = DisplayProxy.instance.swt_display.getSystemMenu
              menu_item = system_menu.getItems.find {|menu_item| menu_item.getID == SWTProxy["ID_#{event_name.upcase}"]}
              menu_item.addListener(SWTProxy[:Selection], &block)
            end
          else
            super
          end
        end
      end

      def add_observer(observer, property_name)
        case property_name.to_s
        when 'visible?' #TODO see if you must handle non-? version and/or move elsewhere
          visibility_notifier = proc do
            observer.call(visible?)
          end
          on_event_show(&visibility_notifier)
          on_event_hide(&visibility_notifier)
          on_event_close(&visibility_notifier)
        else
          super
        end
      end
    end
  end
end
