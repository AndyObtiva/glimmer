require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_display"

module Glimmer
  module SWT
    module CommandHandlers
      class DisplayCommandHandler
        include CommandHandler

        def can_handle?(parent, command_symbol, *args, &block)
          command_symbol.to_s == "display"
        end

        def do_handle(parent, command_symbol, *args, &block)
          GDisplay.instance(*args)
        end
      end
    end
  end
end
