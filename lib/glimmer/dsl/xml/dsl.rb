require 'glimmer/dsl/engine'
Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}

Glimmer::DSL::Engine.add_dynamic_expressions(
  Glimmer::DSL::XML,
  %w[
    xml_text
    xml_tag
    html_tag
    xml
  ]
)
