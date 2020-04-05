require File.dirname(__FILE__) + "/../../command_handler"

module Glimmer
  module SWT
    module CommandHandlers
      class PropertyCommandHandler
        include CommandHandler

        def can_handle?(parent, command_symbol, *args, &block)
          block == nil &&
            args.size > 0 &&
            parent.respond_to?(:set_attribute) &&
            parent.respond_to?(:has_attribute?) &&
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
