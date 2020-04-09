require 'glimmer'
require 'glimmer/dsl/expression'
require 'glimmer/swt/widget_proxy'

module Glimmer
  module DSL
    class WidgetExpression < Expression
      EXCLUDED_KEYWORDS = %w[shell display]

      def can_interpret?(parent, keyword, *args, &block)
        pd keyword
        pd parent
        pd args
        pd block
        pd !EXCLUDED_KEYWORDS.include?(keyword)
        pd widget?(parent)
        pd SWT::WidgetProxy.widget_exists?(keyword)
        !EXCLUDED_KEYWORDS.include?(keyword) &&
          widget?(parent) &&
          SWT::WidgetProxy.widget_exists?(keyword)
      end

      def interpret(parent, keyword, *args, &block)
        pd keyword
        pd parent
        pd args
        pd block
        Glimmer.logger.debug "widget styles are: " + args.inspect
        SWT::WidgetProxy.new(keyword, parent.swt_widget, args)
      end

      def add_content(parent, &block)
        block.call(parent)
      end
    end
  end
end
