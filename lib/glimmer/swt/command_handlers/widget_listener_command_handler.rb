require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_widget"
require File.dirname(__FILE__) + "/../custom_widget"

module Glimmer
  module SWT
    module CommandHandlers
      # TODO rename to observation command handler (or keyword handler)

      class WidgetListenerCommandHandler
        include CommandHandler

        include_package 'org.eclipse.swt.widgets'

        def can_handle?(parent, command_symbol, *args, &block)
          Glimmer.logger.debug "keyword starts with on_: #{command_symbol.to_s.start_with?('on_')}"
          return unless command_symbol.to_s.start_with?('on_')
          Glimmer.logger.debug "block exists?: #{!block.nil?}"
          return unless !block.nil?
          widget_parentage = (parent.is_a?(GWidget) || parent.is_a?(CustomWidget))
          Glimmer.logger.debug "parent is a widget: #{widget_parentage}"
          return unless widget_parentage
          Glimmer.logger.debug "args are empty?: #{args.empty?}"
          return unless args.empty?
          result = parent.can_handle_observation_request?(command_symbol.to_s)
          Glimmer.logger.debug "can add listener? #{result}"
          result
        end

        def do_handle(parent, command_symbol, *args, &block)
          parent.handle_observation_request(command_symbol.to_s, &block)
          ListenerParent.new #TODO refactor and move to models
        end

        #TODO refactor and move to separate file
        class ListenerParent
          include Parent

          def process_block(block)
            #NOOP
          end

        end

      end
    end
  end
end
