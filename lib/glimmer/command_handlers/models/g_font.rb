require_relative 'g_swt'

module Glimmer
  class GFont
    include_package 'org.eclipse.swt.graphics'

    extend Glimmer

    attr_reader :g_widget
    attr_accessor :display

    class << self
      def for(g_widget)
        @instances ||= {}
        unless @instances[g_widget]
          @instances[g_widget] = new(g_widget)
          add_contents(g_widget) {
            on_widget_disposed { |dispose_event|
              @instances.delete(g_widget)
            }
          }
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
      font_properties[:style] = GSWT[*font_properties[:style]]
      font_data_args = [:name, :height, :style].map do |font_property_name|
        font_properties[font_property_name] || send(font_property_name)
      end
      font_datum = FontData.new(*font_data_args)
      Font.new(@display, font_datum)
    end
  end
end
