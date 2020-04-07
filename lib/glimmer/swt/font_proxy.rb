require_relative 'g_swt'

module Glimmer
  module SWT
    class GFont
      ERROR_INVALID_FONT_STYLE = " is an invalid font style! Valid values are :normal, :bold, and :italic"
      FONT_STYLES = [:normal, :bold, :italic]
      include_package 'org.eclipse.swt.graphics'

      attr_reader :g_widget
      attr_accessor :display

      class << self
        def for(g_widget)
          @instances ||= {}
          unless @instances[g_widget]
            @instances[g_widget] = new(g_widget)
            g_widget.on_widget_disposed do |dispose_event|
              @instances.delete(g_widget)
            end
          end
          @instances[g_widget]
        end
      end

      def initialize(g_widget, display = nil)
        @g_widget = g_widget
        @display = display || @g_widget.widget.display
      end

      def g_widget=(a_widget)
        @g_widget = a_widget
        @font_datum = nil
      end

      def font_datum
        @font_datum ||= @g_widget.widget.getFont.getFontData[0]
      end

      def name
        font_datum.getName
      end

      def height
        font_datum.getHeight
      end

      def style
        font_datum.getStyle
      end

      def font(font_properties)
        detect_invalid_font_property(font_properties)
        font_properties[:style] = GSWT[*font_properties[:style]]
        font_data_args = [:name, :height, :style].map do |font_property_name|
          font_properties[font_property_name] || send(font_property_name)
        end
        font_datum = FontData.new(*font_data_args)
        Font.new(@display, font_datum)
      end

      def detect_invalid_font_property(font_properties)
        [font_properties[:style]].flatten.select do |style|
          style.is_a?(Symbol) || style.is_a?(String)
        end.each do |style|
          raise style.to_s + ERROR_INVALID_FONT_STYLE if !FONT_STYLES.include?(style.to_sym)
        end
      end
    end
  end
end
