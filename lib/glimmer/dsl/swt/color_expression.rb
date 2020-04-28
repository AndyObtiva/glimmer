require 'glimmer/dsl/expression'
require 'glimmer/swt/color_proxy'
require 'glimmer/swt/display_proxy'

# TODO consider turning in static expressions rgb/rgba/color

module Glimmer
  module DSL
    module SWT
      class ColorExpression < Expression
        include_package 'org.eclipse.swt.widgets'
  
        def can_interpret?(parent, keyword, *args, &block)
          ['color', 'rgba', 'rgb'].include?(keyword) and
            (1..4).include?(args.count)
        end
  
        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::ColorProxy.new(*args)
        end
      end
    end
  end
end
