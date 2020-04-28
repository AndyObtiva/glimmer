require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/swt/exec_expression'

module Glimmer
  module DSL
    module SWT  
      # Asynchronously executes code block against the SWT Event Loop
      # to manipulate SWT UI objects on the UI thread safely
      class AsyncExecExpression < StaticExpression
        include ExecExpression
      end
    end
  end
end
