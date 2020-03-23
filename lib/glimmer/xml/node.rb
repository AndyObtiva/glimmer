require File.dirname(__FILE__) + "/depth_first_search_iterator"
require File.dirname(__FILE__) + "/xml_visitor"

module Glimmer
  class Node
    include Parent, Glimmer

    attr_accessor :children, :name, :contents, :attributes, :is_name_space, :is_attribute, :name_space, :parent

    def initialize(parent, name, attributes, &contents)
      @is_name_space = false
      @children = []
      @parent = parent
      if (parent and parent.is_name_space)
        @name_space = parent
        @parent = @name_space.parent
      end
      @parent.children << self if @parent
      @name = name
      @contents = contents
      @attributes = attributes
      if @attributes
        @attributes.each_key do |attribute|
          if attribute.is_a?(Node)
            attribute.is_attribute = true
            attribute.parent.children.delete(attribute) if attribute.parent
            attribute.parent = nil #attributes do not usually have parents
          end
        end
        Glimmer.logger.debug(attributes)
      end
    end

    def method_missing(symbol, *args, &block)
      @is_name_space = true
      parent.children.delete(self) if parent
      Glimmer.add_contents(self) {@tag = super}
      @tag
    end

    def to_xml
      xml_visitor = XmlVisitor.new
      DepthFirstSearchIterator.new(self, xml_visitor).iterate
      xml_visitor.document
    end

    def process_block(block)
      return_value = block.call(@widget)
      if return_value.is_a?(String) and !@children.include?(return_value)
        text = return_value
        first_match = text.match(/[#][^{]+[{][^}]+[}]/)
        match = first_match
        while (match)
          Glimmer.module_eval(text_command(match.pre_match))
          tag_text = match.to_s
          Glimmer.module_eval(rubyize(tag_text))
          text = tag_text
          post_match = match.post_match
          match = text.match(/[#]\w+[{]\w+[}]/)
        end
        Glimmer.module_eval(text_command(post_match)) if post_match
        @children << return_value unless first_match
      end
    end

    def text_command(text)
      "text \"#{text}\""
    end

    def rubyize(text)
      text = text.gsub(/[}]/, '"}')
      text = text.gsub(/[{]/, '{"')
        text = text.gsub(/[#]/, '')
      end

      #override Object default id method and route it to Glimmer engine
      def id
        method_missing(:id)
      end

    end
end
