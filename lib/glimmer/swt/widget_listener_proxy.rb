module Glimmer
  module SWT
    # Proxy for widget listeners
    #
    # Follows the Proxy Design Pattern
    class WidgetListenerProxy

      attr_reader :swt_listener

      # TODO capture its widget and support unregistering 

      def initialize(swt_listener)
        @swt_listener = swt_listener
      end
    end
  end
end
