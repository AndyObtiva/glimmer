require 'glimmer/dsl/engine'
Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}

Glimmer::DSL::Engine.add_dynamic_expressions(
  Glimmer::DSL::CSS,
  %w[
    rule
    dynamic_property
  ]
)
