require 'glimmer/dsl/engine'
Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}

# Glimmer DSL expression configuration module
#
# When DSL engine interprets an expression, it attempts to handle
# with expressions listed here in the order specified.

# Every expression has a corresponding Expression subclass
# in glimmer/dsl

Glimmer::DSL::Engine.add_dynamic_expressions(
  Glimmer::DSL::SWT,
  %w[
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
)
