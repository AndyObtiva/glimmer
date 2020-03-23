require File.dirname(__FILE__) + "/../../command_handler"
require File.dirname(__FILE__) + "/../g_shell"

module Glimmer
  module SWT
    module CommandHandlers
      class ShellCommandHandler
        include CommandHandler

        def can_handle?(parent, command_symbol, *args, &block)
          command_symbol.to_s == "shell"
        end

        def do_handle(parent, command_symbol, *args, &block)
          GShell.send(:new, *args)
        end
      end
    end
  end
end
