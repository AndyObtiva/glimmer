require 'glimmer'
require 'glimmer/dsl/expression'
require 'glimmer/swt/widget_proxy'

module Glimmer
  module DSL
    class WidgetExpression < Expression
      def can_interpret?(parent, keyword, *args, &block)
        keyword != "shell" &&
          widget?(parent) &&
          DataBinding::WidgetProxy.widget_exists?(keyword)
      end

      def interpret(parent, keyword, *args, &block)
        Glimmer.logger.debug "widget styles are: " + args.inspect
        DataBinding::WidgetProxy.new(keyword, parent.swt_object, args)
      end

      def add_content(parent, &block)
        block.call(parent)
      end
    end
  end
end
