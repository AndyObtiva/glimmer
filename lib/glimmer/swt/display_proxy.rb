require 'glimmer/swt/widget_listener_proxy'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.widgets.Display
    #
    # Maintains a singleton instance since SWT only supports
    # a single active display at a time.
    #
    # Supports SWT Display's very useful asyncExec and syncExec methods
    # to support proper multi-threaded manipulation of SWT UI objects
    #
    # Invoking `#swt_display` returns the SWT Display object wrapped by this proxy
    #
    # Follows the Proxy Design Pattern
    class DisplayProxy
      include_package 'org.eclipse.swt.widgets'

      class << self
        # Returns singleton instance
        def instance(*args)
          if @instance.nil? || @instance.swt_display.isDisposed
            @instance = new(*args)
          end
          @instance
        end
      end

      # SWT Display object wrapped
      attr_reader :swt_display

      def initialize(*args)
        @swt_display = Display.new(*args)
      end

      def dispose
        @swt_display.dispose
      end

      # Executes code block asynchronously with respect to SWT UI thread
      def async_exec(&block)
        @swt_display.asyncExec(&block)
      end

      # Executes code block synchronously with respect to SWT UI thread
      def sync_exec(&block)
        @swt_display.syncExec(&block)
      end

      def can_handle_observation_request?(observation_request)
        observation_request = observation_request.to_s
        if observation_request.start_with?('on_event_')
          constant_name = observation_request.sub(/^on_event_/, '')
          SWTProxy.has_constant?(constant_name)
        else
          false
        end
      end

      def handle_observation_request(observation_request, &block)
        if observation_request.start_with?('on_event_')
          constant_name = observation_request.sub(/^on_event_/, '')
          add_swt_event_listener(constant_name, &block)
        end
      end

      def add_swt_event_listener(swt_constant, &block)
        event_type = SWTProxy[swt_constant]
        pd 'adding filter'
        pd swt_constant
        @swt_display.addFilter(event_type, &block)
        #WidgetListenerProxy.new(@swt_display.getListeners(event_type).last)
      end
    end
  end
end
