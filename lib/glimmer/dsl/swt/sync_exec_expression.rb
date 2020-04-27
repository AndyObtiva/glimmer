require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/swt/exec_expression'

module Glimmer
  module DSL
    # Synchronously executes code block against the SWT Event Loop
    # to manipulate SWT UI objects on the UI thread safely with
    # immediate priority when needed.
    class SyncExecExpression < StaticExpression
      include ExecExpression
    end
  end
end
