require 'glimmer/css/rule_set'

module Glimmer
  module CSS
    class StyleSheet
      attr_reader :rule_sets

      def initialize
        @rule_sets = []
      end

      def to_css
        rule_sets.map(&:to_css).join
      end

      alias to_s to_css      
    end
  end
end
