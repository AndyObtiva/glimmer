require 'glimmer/dsl/expression'
require 'glimmer/swt/color_proxy'
require 'glimmer/swt/display_proxy'

# TODO consider turning static keywords like rgba/rgb into methods
# Support color keyword

module Glimmer
  module DSL
    class ColorExpression < Expression
      include_package 'org.eclipse.swt.widgets'

      def can_interpret?(parent, keyword, *args, &block)
        ['rgba', 'rgb'].include?(keyword) &&
          (3..5).include?(args.count)
      end

      def interpret(parent, keyword, *args, &block)
        if args.first.is_a?(Display) || args.first.nil?
          display = args.delete_at(0)
        elsif widget?(parent)
          display = parent.swt_display
        else
          display = SWT::DisplayProxy.instance.swt_display
        end
        SWT::ColorProxy.new(display, *args)
      end
    end
  end
end
