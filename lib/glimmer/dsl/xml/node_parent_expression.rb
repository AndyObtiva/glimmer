require 'glimmer'
require 'glimmer/dsl/parent_expression'
require 'glimmer/xml/node'

module Glimmer
  module DSL
    module XML
      module NodeParentExpression
        include ParentExpression
        include Glimmer

        def add_content(parent, &block)
          return_value = block.call(parent)      
          if !return_value.is_a?(Glimmer::XML::Node) and !parent.children.include?(return_value)
            text = return_value.to_s
            first_match = text.match(/[#][^{]+[{][^}]+[}]/)
            match = first_match
            while (match)
              instance_eval(parent.text_command(match.pre_match))
              tag_text = match.to_s
              instance_eval(parent.rubyize(tag_text))
              text = tag_text
              post_match = match.post_match
              match = text.match(/[#]\w+[{]\w+[}]/)
            end
            instance_eval(parent.text_command(post_match)) if post_match
            parent.children << return_value unless first_match
          end
        end
      end
    end
  end
end
