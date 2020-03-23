module Glimmer
  module SWT
    # Wrapper around SWT Display
    class GDisplay
      include_package 'org.eclipse.swt.widgets'

      class << self
        def instance(*args)
          if @instance.nil? || @instance.display.isDisposed
            @instance = GDisplay.new(*args)
          end
          @instance
        end
      end

      # SWT Display object wrapped
      attr_reader :display

      def initialize(*args)
        @display = Display.new(*args)
      end

      def dispose
        @display.dispose
      end
    end
  end
end
