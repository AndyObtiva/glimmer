module CommandHandler
  def can_handle?(parent, command_symbol, *args, &block)
    raise "must be implemented by a class"
  end
  def do_handle(parent, command_symbol, *args, &block)
    raise "must be implemented by a class"
  end
end