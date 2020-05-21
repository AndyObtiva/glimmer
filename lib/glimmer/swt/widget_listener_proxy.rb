module Glimmer
  module SWT
    # Proxy for widget listeners
    #
    # Follows the Proxy Design Pattern
    class WidgetListenerProxy

      attr_reader :swt_widget, :swt_listener, :widget_add_listener_method, :swt_listener_class, :swt_listener_method, :event_type, :swt_constant

      def initialize(swt_widget:, swt_listener:, widget_add_listener_method: nil, swt_listener_class: nil, swt_listener_method: nil, event_type: nil, swt_constant: nil)
        @swt_widget = swt_widget
        @swt_listener = swt_listener
        @widget_add_listener_method = widget_add_listener_method
        @swt_listener_class = swt_listener_class
        @swt_listener_method = swt_listener_method
        @event_type = event_type
        @swt_constant = swt_constant
      end
      
      def widget_remove_listener_method
        @widget_add_listener_method.sub('add', 'remove')
      end      
      
      def unregister
        # TODO consider renaming to deregister (and in Observer too)
        if @event_type
          @swt_widget.removeListener(@event_type, @swt_listener)
        else
          @swt_widget.send(widget_remove_listener_method, @swt_listener)
        end
      end
    end
  end
end
