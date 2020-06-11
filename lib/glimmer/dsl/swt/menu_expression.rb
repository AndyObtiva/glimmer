require 'glimmer'
require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/menu_proxy'

module Glimmer
  module DSL
    module SWT
      class MenuExpression < StaticExpression
        include ParentExpression
  
        include_package 'org.eclipse.swt.widgets'
  
        def can_interpret?(parent, keyword, *args, &block)
          initial_condition = (keyword == 'menu')
          if initial_condition
            if parent.respond_to?(:swt_widget)
              return true
            else
              raise Glimmer::Error, "menu may only be nested under a widget (like shell or another menu)!"
            end
          end
          false
        end
  
        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::MenuProxy.new(parent, args)
        end
      end
    end
  end
end
