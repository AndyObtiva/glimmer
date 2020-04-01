require 'super_module'

module Glimmer
  module SWT
    module CustomShell
      include SuperModule
      include Glimmer::SWT::CustomWidget

      # Classes may override
      def open
        if body_root.opened_before?
          body_root.open
          @initially_focused_widget.widget.setFocus
        else
          @initially_focused_widget.widget.setFocus
          body_root.open
        end
      end

      # DO NOT OVERRIDE. JUST AN ALIAS FOR `#open`. OVERRIDE `#open` INSTEAD.
      def show
        open
      end

      def hide
        body_root.hide
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
