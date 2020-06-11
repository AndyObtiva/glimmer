require 'glimmer/dsl/engine'
# Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f} # cannot in Opal
require 'glimmer/dsl/xml/text_expression'
require 'glimmer/dsl/xml/tag_expression'
require 'glimmer/dsl/xml/xml_expression'
require 'glimmer/dsl/xml/html_expression'
require 'glimmer/dsl/xml/meta_expression'
require 'glimmer/dsl/xml/name_space_expression'

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
