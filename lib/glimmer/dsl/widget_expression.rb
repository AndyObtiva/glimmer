require 'glimmer'
require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    class WidgetExpression < Expression
      EXCLUDED_KEYWORDS = %w[shell display]

      def can_interpret?(parent, keyword, *args, &block)
        !EXCLUDED_KEYWORDS.include?(keyword) and
          widget?(parent) and
          SWT::WidgetProxy.widget_exists?(keyword)
      end

      def interpret(parent, keyword, *args, &block)
        Glimmer.logger.debug "widget styles are: " + args.inspect
        SWT::WidgetProxy.new(keyword, parent.swt_widget, args)
      end

      def add_content(parent, &block)
        block.call(parent)
      end
    end
  end
end

require 'glimmer/swt/widget_proxy'
