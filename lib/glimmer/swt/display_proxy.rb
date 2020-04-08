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
          if @instance.nil? || @instance.display.isDisposed
            @instance = new(*args)
          end
          @instance
        end
      end

      # SWT Display object wrapped
      attr_reader :swt_display

      def initialize(*args)
        @display = Display.new(*args)
      end

      def dispose
        @display.dispose
      end

      # Executes code block asynchronously with respect to SWT UI thread
      def async_exec(&block)
        @display.asyncExec(&block)
      end

      # Executes code block synchronously with respect to SWT UI thread
      def sync_exec(&block)
        @display.syncExec(&block)
      end
    end
  end
end
