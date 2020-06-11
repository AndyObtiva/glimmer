module Glimmer
  module Opal
    class Label
      attr_reader :text

      def initialize(parent, args)
        @parent = parent
        @args = args
        @parent.add_child(self)
      end

      def text=(value)
        @text = value
        redraw
      end

      def redraw
        old_dom = @dom
        @dom = nil
        old_dom.replace dom
      end

      def dom
        label_text = @text
        @dom ||= DOM {
          label label_text
        }
      end
    end
  end
end
