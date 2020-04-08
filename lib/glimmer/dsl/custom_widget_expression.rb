require 'glimmer/dsl/expression'
require 'glimmer/ui/custom_widget'
require 'glimmer/ui/custom_shell'

module Glimmer
  module DSL
    class CustomWidgetExpression < Expression
      def can_interpret?(parent, keyword, *args, &block)
        custom_widget_class = UI::CustomWidget.for(keyword)
        custom_widget_class &&
          (widget?(parent) || custom_widget_class.ancestors.include?(UI::CustomShell))
      end

      def interpret(parent, keyword, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        Glimmer.logger.debug "Custom widget #{keyword} styles are: [" + args.inspect + "] and options are: #{options}"
        UI::CustomWidget.for(keyword).new(parent, *args, options, &block)
      end

      def add_content(parent, &block)
        # TODO consider avoiding source_location
        if block.source_location == parent.content&.__getobj__.source_location
          parent.content.call(parent) unless parent.content.called?
        else
          block.call(parent)
        end
      end
    end
  end
end
