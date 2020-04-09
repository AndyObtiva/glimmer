require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/tree_items_binding'

module Glimmer
  module DSL
    class TreeItemsDataBindingExpression < Expression
      include_package 'org.eclipse.swt.widgets'

      def can_interpret?(parent, keyword, *args, &block)
        keyword == "items" &&
          block.nil? &&
          widget?(parent) &&
          parent.widget.is_a?(Tree) &&
          args.size == 2 &&
          args[0].is_a?(DataBinding::ModelBinding) &&
          !args[0].evaluate_property.is_a?(Array) &&
          args[1].is_a?(Array) &&
          !args[1].empty? &&
          args[1].first.is_a?(Hash)
      end

      def interpret(parent, keyword, *args, &block)
        model_binding = args[0]
        tree_properties = args[1]
        DataBinding::TreeItemsBinding.new(parent, model_binding, tree_properties)
      end
    end
  end
end
