require 'glimmer/dsl/static_expression'
require 'glimmer/swt/swt_proxy'

# TODO consider turning static keywords like bind into methods

module Glimmer
  module DSL
    # Responsible for returning SWT constant values
    #
    # Named SwtExpression (not SWTExpression) so that the DSL engine
    # discovers quickly by convention
    class SwtExpression < StaticExpression
      def can_interpret?(parent, keyword, *args, &block)
        block.nil? &&
          args.size > 0
      end

      def interpret(parent, keyword, *args, &block)
        SWT::SWTProxy[*args]
      end
    end
  end
end
