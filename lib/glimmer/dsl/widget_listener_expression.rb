require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    class WidgetListenerExpression < Expression
      include_package 'org.eclipse.swt.widgets'

      def can_interpret?(parent, keyword, *args, &block)
        Glimmer.logger&.debug "keyword starts with on_: #{keyword.start_with?('on_')}"
        return false unless keyword.start_with?('on_')
        widget_parentage = widget?(parent)
        Glimmer.logger&.debug "parent is a widget: #{widget_parentage}"
        return false unless widget_parentage
        Glimmer.logger&.debug "block exists?: #{!block.nil?}"
        raise Glimmer::Error, "Listener is missing block for keyword: #{keyword}" unless block_given?
        Glimmer.logger&.debug "args are empty?: #{args.empty?}"
        raise Glimmer::Error, "Invalid listener arguments for keyword: #{keyword}(#{args.inspect})" unless args.empty?
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
