require 'glimmer/dsl/engine'
Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}

module Glimmer
  # Glimmer DSL expression configuration module
  #
  # When DSL engine interprets an expression, it attempts to handle
  # with expressions listed here in the order specified.
  module DSL
    # Every expression has a corresponding AbstractExpression subclass
    # in glimmer/dsl
    # TODO rename to dynamic_expressions in the future when supporting static expressions
    Engine.dynamic_expressions = %w[
      layout
      widget_listener
      combo_selection_data_binding
      list_selection_data_binding
      tree_items_data_binding
      table_items_data_binding
      data_binding
      color
      property
      widget
      custom_widget
    ]
  end
end
