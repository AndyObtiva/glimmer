require 'glimmer/dsl/xml/node_parent_expression'
require 'glimmer/dsl/xml/xml_expression'
require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/top_level_expression'

module Glimmer
  module DSL
    module XML
      # This static html expression flips the DSL switch on for 
      # XML DSL in Glimmer
      class HtmlExpression < StaticExpression
        include TopLevelExpression
        include NodeParentExpression

        def interpret(parent, keyword, *args, &block)
          xml_expression.interpret(parent, keyword, *args, &block)
        end

        def xml_expression
          @xml_expression ||= XmlExpression.new
        end
      end
    end
  end
end
