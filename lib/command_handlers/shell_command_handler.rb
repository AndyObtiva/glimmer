require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_shell"

class ShellCommandHandler
  include CommandHandler

  def can_handle?(parent, command_symbol, *args, &block)
    command_symbol.to_s == "shell"
  end

  def do_handle(parent, command_symbol, *args, &block)
    RShell.send(:new, *args)
  end

end