require_relative 'r_swt'

class RFont
  include_package 'org.eclipse.swt.graphics'

  extend Glimmer

  attr_reader :r_widget
  attr_accessor :display

  class << self
    def for(r_widget)
      @instances ||= {}
      unless @instances[r_widget]
        @instances[r_widget] = new(r_widget)
        add_contents(r_widget) {
          on_widget_disposed { |dispose_event|
            @instances.delete(r_widget)
          }
        }
      end
      @instances[r_widget]
    end
  end

  def initialize(r_widget, display = nil)
    @r_widget = r_widget
    @display = display || @r_widget.widget.display
  end

  def r_widget=(a_widget)
    @r_widget = a_widget
    @font_datum = nil
  end

  def font_datum
    @font_datum ||= @r_widget.widget.getFont.getFontData[0]
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
    font_properties[:style] = RSwt[*font_properties[:style]]
    font_data_args = [:name, :height, :style].map do |font_property_name|
      font_properties[font_property_name] || send(font_property_name)
    end
    font_datum = FontData.new(*font_data_args)
    Font.new(@display, font_datum)
  end
end
