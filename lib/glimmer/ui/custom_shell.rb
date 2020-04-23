require 'glimmer/error'

module Glimmer
  module UI
    module CustomShell
      include SuperModule
      include Glimmer::UI::CustomWidget

      def initialize(parent, *swt_constants, options, &content)
        super
        raise Error, 'Invalid custom shell body root! Must be a shell or another custom shell.' unless body_root.swt_widget.is_a?(org.eclipse.swt.widgets.Shell)
      end

      # Classes may override
      def open
        body_root.open
      end

      # DO NOT OVERRIDE. JUST AN ALIAS FOR `#open`. OVERRIDE `#open` INSTEAD.
      def show
        open
      end

      def close
        body_root.close
      end

      def hide
        body_root.hide
      end

      def visible?
        body_root.visible?
      end

      def center
        body_root.center
      end

      def start_event_loop
        body_root.start_event_loop
      end
    end
  end
end
