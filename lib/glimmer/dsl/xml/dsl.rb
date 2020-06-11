require 'glimmer/dsl/engine'
Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}

module Glimmer
  module DSL
    module XML
      Engine.add_dynamic_expressions(
        XML,
        %w[
          text
          tag
          xml
        ]
      )
    end
  end
end
