require 'glimmer/dsl/xml/node_parent_expression'
require 'glimmer/dsl/expression'
require 'glimmer/xml/node'

module Glimmer
  module DSL
    module XML
      class HtmlTagExpression < Expression
        include NodeParentExpression

        def can_interpret?(parent, keyword, *args, &block) 
          (parent == nil or parent.is_a?(Glimmer::XML::Node)) and
            (args.size == 0 or ((args.size == 1) and ((args[0].is_a?(Hash)) or (args[0].is_a?(Hash)))))
        end

        def interpret(parent, keyword, *args, &block)
          attributes = Hash.new
          attributes = args[0] if (args.size == 1)
          append_id_and_class_attributes(keyword.to_s, attributes)
          tag_name = parse_tag_name(keyword.to_s)
          Glimmer::XML::Node.new(parent, tag_name, attributes, &block)
        end

        def parse_tag_name(command)
          match_data = command.match("_")
          if (match_data.to_a.size > 0)
            command.match("_").pre_match
          else
            command
          end
        end

        def append_id_and_class_attributes(command, attributes)
          class_only_match = command.match("__.+").to_s
          if class_only_match.length > 0
            class_value = class_only_match[2, class_only_match.length]
          else
            match_data = command.match("_[^_]+")
            return unless match_data
            match = match_data.to_s
            id_value = match[1, match.length] if match.length > 0
            attributes[:id] = id_value if id_value
            match2 = match_data.post_match.match("_[^_]+").to_s if match_data.post_match
            class_value = match2[1, match2.length] if match2.length > 0
          end
          attributes[:class] = class_value if class_value
        end
      end
    end
  end
end
