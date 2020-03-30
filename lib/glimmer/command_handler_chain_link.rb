module Glimmer
  class CommandHandlerChainLink
    def initialize(command_handler)
      @command_handler = command_handler
    end
    def chain_to(next_chain_link)
      @next_chain_link = next_chain_link
    end
    def handle(parent, command_symbol, *args, &block)
      if (@command_handler.can_handle?(parent, command_symbol, *args, &block))
        Glimmer.logger.debug "#{@command_handler.class.to_s} will handle command: #{command_symbol} with arguments #{args}"
        return @command_handler.do_handle(parent, command_symbol, *args, &block)
      elsif @next_chain_link
        return @next_chain_link.handle(parent, command_symbol, *args, &block)
      else
        # TODO see if we need a better response here (e.g. dev mode error raising vs production mode silent failure)
        # Glimmer.logger.error "Command: #{command_symbol} cannot be handled!" unless command_symbol.to_s.start_with?('to_')
        Glimmer.logger.debug "Command: #{command_symbol} cannot be handled!"
        return nil
      end
    end
  end
end
