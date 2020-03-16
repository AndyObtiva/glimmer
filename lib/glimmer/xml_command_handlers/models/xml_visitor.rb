require File.dirname(__FILE__) + "/node_visitor"

module Glimmer
  class XmlVisitor < NodeVisitor

    attr_reader :document

    def initialize
      @document = ""
    end

    def process_before_children(node)
      if (node.is_a?(String))
        @document << node
        return
      end
      begin_open_tag(node)
      append_attributes(node) if node.attributes
      end_open_tag(node)
    end

    def process_after_children(node)
      return if (node.is_a?(String))
      append_close_tag(node)
    end

    def begin_open_tag(node)
      @document << "<"
      @document << "#{node.name_space.name}:" if node.name_space
      @document << node.name
    end

    def end_open_tag(node)
      if (node.contents)
        @document << ">"
      else
        @document << " " if node.attributes.keys.size > 0
        @document << "/>"
      end
    end

    def append_close_tag(node)
      if (node.contents)
        @document << "</"
        @document << "#{node.name_space.name}:" if node.name_space
        @document << "#{node.name}>"
      end
    end

    def append_attributes(node)
      Glimmer.logger.debug "Take 3"
      Glimmer.logger.debug(node.attributes)
      node.attributes.each_key do |attribute|
        attribute_name = attribute
        attribute_name = "#{attribute.name_space.name}:#{attribute.name}" if attribute.is_a?(Node)
        @document << " #{attribute_name}=\"#{node.attributes[attribute]}\""
      end
    end

  end
end
