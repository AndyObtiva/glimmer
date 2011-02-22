class CommandHandlerChainLink
  def initialize(command_handler)
    @command_handler = command_handler
  end
  def chain_to(next_chain_link)
    @next_chain_link = next_chain_link
  end
  def handle(parent, command_symbol, *args, &block)
    if (@command_handler.can_handle?(parent, command_symbol, *args, &block))
      puts "#{@command_handler.class.to_s} will handle command: #{command_symbol} with arguments #{args}"
      return @command_handler.do_handle(parent, command_symbol, *args, &block)
    elsif @next_chain_link
      return @next_chain_link.handle(parent, command_symbol, *args, &block)
    else
      puts "Command: #{command_symbol} cannot be handled!"
      return nil
    end
  end
end
