module Glimmer
  # rename to keyword handler

  module CommandHandler
    def can_handle?(parent, command_symbol, *args, &block)
      raise "must be implemented by a class"
    end

    # TODO rename do_handle to just handle

    def do_handle(parent, command_symbol, *args, &block)
      raise "must be implemented by a class"
    end
  end
end
