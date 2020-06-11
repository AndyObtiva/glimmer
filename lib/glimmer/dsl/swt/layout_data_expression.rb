require 'glimmer'
require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/layout_data_proxy'

# TODO consider turning static keywords like layout_data into methods

module Glimmer
  module DSL
    module SWT
      class LayoutDataExpression < StaticExpression
        include ParentExpression
  
        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'layout_data' and
            parent.respond_to?(:swt_widget)
        end
  
        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::LayoutDataProxy.new(parent, args)
        end
      end
    end
  end
end
