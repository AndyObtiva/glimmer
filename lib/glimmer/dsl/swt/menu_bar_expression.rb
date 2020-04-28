require 'glimmer'
require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/menu_proxy'

module Glimmer
  module DSL
    module SWT
      class MenuBarExpression < StaticExpression
        include ParentExpression
  
        include_package 'org.eclipse.swt.widgets'
  
        def can_interpret?(parent, keyword, *args, &block)
          initial_condition = (keyword == 'menu_bar')
          if initial_condition
            if parent.swt_widget.is_a?(Shell)
              return true
            else
              raise Glimmer::Error, "menu_bar may only be nested under a shell!"
            end
          end
          false
        end
  
        def interpret(parent, keyword, *args, &block)
          args = args.unshift(:bar)
          Glimmer::SWT::MenuProxy.new(parent, args)
        end
      end
    end
  end
end
