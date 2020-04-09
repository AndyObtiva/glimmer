require 'glimmer'
require 'glimmer/data_binding/observable'
require 'glimmer/data_binding/observer'

module Glimmer
  module DataBinding
    # SWT List widget selection binding
    class ListSelectionBinding
      include Glimmer
      include Observable
      include Observer

      attr_reader :widget_proxy

      PROPERTY_TYPE_UPDATERS = {
        :string => lambda { |widget_proxy, value| widget_proxy.swt_widget.select(widget_proxy.swt_widget.index_of(value.to_s)) },
        :array => lambda { |widget_proxy, value| widget_proxy.swt_widget.selection=(value || []).to_java(:string) }
      }

      PROPERTY_EVALUATORS = {
        :string => lambda do |selection_array|
          return nil if selection_array.empty?
          selection_array[0]
        end,
        :array => lambda do |selection_array|
          selection_array
        end
      }

      # Initialize with list widget and property_type
      # property_type :string represents default list single selection
      # property_type :array represents list multi selection
      def initialize(widget_proxy, property_type)
        property_type = :string if property_type.nil? or property_type == :undefined
        @widget_proxy = widget_proxy
        @property_type = property_type
        @widget_proxy.on_widget_disposed do |dispose_event|
          unregister_all_observables
        end
      end

      def call(value)
        PROPERTY_TYPE_UPDATERS[@property_type].call(@widget_proxy, value) unless evaluate_property == value
      end

      def evaluate_property
        selection_array = @widget_proxy.swt_widget.send('selection').to_a
        PROPERTY_EVALUATORS[@property_type].call(selection_array)
      end
    end
  end
end
