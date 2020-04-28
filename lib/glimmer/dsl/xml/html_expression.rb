require 'glimmer/dsl/xml/node_parent_expression'
require 'glimmer/dsl/xml/html_tag_expression'
require 'glimmer/dsl/static_expression'

module Glimmer
  module DSL
    module XML
      # This static html expression flips the DSL switch on for 
      # XML DSL in Glimmer
      class HtmlExpression < StaticExpression
        include NodeParentExpression

        def interpret(parent, keyword, *args, &block)
          html_tag_expression.interpret(parent, keyword, *args, &block)
        end

        def html_tag_expression
          @html_tag_expression ||= HtmlTagExpression.new
        end
      end
    end
  end
end
