module Glimmer
  module CSS
    class RuleSet
      attr_reader :selector, :properties

      def initialize(selector)
        @selector = selector
        @properties = []
      end

      def add_property(keyword, *args)
        keyword = keyword.to_s.downcase.gsub('_', '-')
        args = args.map(&:to_s).join(' ')
        @properties[keyword] = args
      end

      def to_css
        css = "#{@selector} {\n"
        @properties.each do |name, value|
          css << "  #{name}: #{value};\n"
        end
        css << "}"
      end

      alias to_s to_css      
    end
  end
end
