require 'glimmer/dsl/engine'
# Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f} # cannot in Opal
require 'glimmer/dsl/css/rule_expression'
require 'glimmer/dsl/css/dynamic_property_expression'
require 'glimmer/dsl/css/css_expression'
require 'glimmer/dsl/css/s_expression'
require 'glimmer/dsl/css/pv_expression'

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
