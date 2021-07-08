require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/top_level_expression'
require 'glimmer/dsl/bind_expression'

module Glimmer
  module DSL
    module SWT
      class BindExpression < Glimmer::DSL::StaticExpression
        include Glimmer::DSL::TopLevelExpression
        include Glimmer::DSL::BindExpression
      end
    end
  end
end
