require 'glimmer/dsl/static_expression'
require 'glimmer/swt/color_proxy'
require 'glimmer/swt/display_proxy'

module Glimmer
  module DSL
    module SWT
      class ColorExpression < StaticExpression
        include_package 'org.eclipse.swt.widgets'
  
        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::ColorProxy.new(*args)
        end
      end
    end
  end
end
