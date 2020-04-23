require 'glimmer/dsl/expression'
require 'glimmer/swt/display_proxy'

module Glimmer
  module DSL
    class WidgetListenerExpression < Expression
      include_package 'org.eclipse.swt.widgets'

      def can_interpret?(parent, keyword, *args, &block)
        Glimmer.logger&.debug "keyword starts with on_: #{keyword.start_with?('on_')}"
        return false unless keyword.start_with?('on_')
        widget_or_display_parentage = widget?(parent) || parent.is_a?(SWT::DisplayProxy)
        Glimmer.logger&.debug "parent is a widget or display: #{widget_or_display_parentage}"
        return false unless widget_or_display_parentage
        Glimmer.logger&.debug "block exists?: #{!block.nil?}"
        raise Glimmer::Error, "Listener is missing block for keyword: #{keyword}" unless block_given?
        Glimmer.logger&.debug "args are empty?: #{args.empty?}"
        raise Glimmer::Error, "Invalid listener arguments for keyword: #{keyword}(#{args})" unless args.empty?
        result = parent.can_handle_observation_request?(keyword)
        Glimmer.logger&.debug "can add listener? #{result}"
        raise Glimmer::Error, "Invalid listener keyword: #{keyword}" unless result
        true
      end

      def interpret(parent, keyword, *args, &block)
        parent.handle_observation_request(keyword, &block)
      end
    end
  end
end
