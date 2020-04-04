require 'super_module'

module Glimmer
  module SWT
    module CustomShell
      include SuperModule
      include Glimmer::SWT::CustomWidget

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
