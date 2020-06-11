module Glimmer
  module Opal
    class Shell
      def initialize(args)
        @args = args
        @children = []
        $document.ready do
          $document.body.replace(dom)
        end
      end      

      def text
        $document.title
      end

      def text=(value)
        $document.title = value
      end

      def add_child(child)
        return if @children.include?(child)
        @children << child
        dom << child.dom
      end

      def dom
        @dom ||= DOM {
          body {
          }
        }
      end
    end
  end
end
