require 'glimmer/error'
require 'glimmer/dsl/engine'
require 'glimmer/dsl/expression'
require 'glimmer/swt/widget_proxy'
require 'glimmer/ui/custom_widget'

module Glimmer
  module DSL
    # Represents a StaticExpression for expressions where
    # the keyword does not vary dynamically. These static keywords are then
    # predefined as methods in Glimmer instead of needing method_missing
    #
    # StaticExpression subclasses may optionally implement `#can_interpret?`
    # (not needed if it only checks for keyword)
    #
    # StaticExpression subclasses must define `#interpret`.
    # 
    # The direct parent namespace of a StaticExpression subclass must match the DSL name (case-insensitive)
    # (e.g. Glimmer::DSL::SWT::WidgetExpression has a DSL of :swt)
    class StaticExpression < Expression
      class << self
        attr_reader :dsl, :keyword
  
        def inherited(base)
          base_name_parts = base.name.split(/::/)
          base.keyword = base_name_parts.last.sub(/Expression$/, '').underscore
          base.dsl = base_name_parts[-2].downcase.to_sym
          Glimmer::DSL::Engine.add_static_expression(base.new)
        end

        protected

        attr_writer :dsl, :keyword
      end

      # Subclasses may optionally implement
      def can_interpret?(parent, keyword, *args, &block)
        true
      end
    end
  end
end
