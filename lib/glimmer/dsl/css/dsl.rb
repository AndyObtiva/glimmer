require 'glimmer/dsl/engine'
Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}

module Glimmer
  module DSL
    module CSS
      Engine.add_dynamic_expressions(
        CSS,
        %w[
          rule
          dynamic_property
        ]
      )
    end
  end
end
