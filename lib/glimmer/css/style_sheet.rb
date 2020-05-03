require 'glimmer/css/rule'

module Glimmer
  module CSS
    class StyleSheet
      attr_reader :rules

      def initialize
        @rules = []
      end

      def to_css
        rules.map(&:to_css).join
      end

      alias to_s to_css      
    end
  end
end
