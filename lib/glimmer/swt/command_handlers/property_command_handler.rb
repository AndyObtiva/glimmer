require File.dirname(__FILE__) + "/../../command_handler"

module Glimmer
  module SWT
    module CommandHandlers
      class PropertyCommandHandler
        include CommandHandler

        def can_handle?(parent, command_symbol, *args, &block)
          parent.respond_to?(:set_attribute) and
          parent.respond_to?(:has_attribute?) and
          args.size > 0 and
          block == nil and
          parent.has_attribute?(command_symbol, *args)
        end

        def do_handle(parent, command_symbol, *args, &block)
          parent.set_attribute(command_symbol, *args)
          nil
        end
      end
    end
  end
end
