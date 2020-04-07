require File.dirname(__FILE__) + "/../../command_handler"

module Glimmer
  module SWT
    module CommandHandlers
      class ObserveCommandHandler
        REGEX_NESTED_OR_INDEXED_PROPERTY = /([^\[]+)(\[[^\]]+\])?/
        include CommandHandler

        def can_handle?(parent, command_symbol, *args, &block)
          command_symbol.to_s == "observe" and
          (
            (
              (args.size == 2) and
                (
                  args[1].is_a?(Symbol) or
                  args[1].is_a?(String)
                )
            )
          ) and
            !block.nil?
        end

        def do_handle(parent, command_symbol, *args, &block)
          observer = Observer.proc(&block)
          if args[1].to_s.match(REGEX_NESTED_OR_INDEXED_PROPERTY)
            observer.observe(ModelBinding.new(args[0], args[1]))
          else
            observer.observe(args[0], args[1])
          end
        end
      end
    end
  end
end
