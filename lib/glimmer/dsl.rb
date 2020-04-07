require 'glimmer/dsl/engine'

module Glimmer
  # Glimmer DSL expression configuration module
  #
  # When DSL engine interprets an expression, it attempts to handle
  # with expressions listed here in the order specified.
  module DSL
    # Every expression has a corresponding AbstractExpression subclass
    # in glimmer/dsl
    Engine.expressions = %w[
      observe
      display
      shell
      layout_data
      layout
      widget_listener
      bind
      tab_item
      combo_selection_data_binding
      list_selection_data_binding
      tree_items_data_binding
      tree_properties_data_binding
      table_items_data_binding
      table_column_properties_data_binding
      data_binding
      color
      property
      widget
      custom_widget
    ]
  end
end
