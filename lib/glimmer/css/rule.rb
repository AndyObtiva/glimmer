module Glimmer
  module CSS
    class Rule
      attr_reader :selector, :properties

      def initialize(selector)
        @selector = selector
        @properties = {}
      end

      def add_property(keyword, *args)
        keyword = keyword.to_s.downcase.gsub('_', '-')
        @properties[keyword] = args.first
      end

      def to_css
        css = "#{@selector}{"
        css << @properties.map { |name, value| "#{name}:#{value}" }.join(';')
        css << "}"
      end

      alias to_s to_css      
    end
  end
end
