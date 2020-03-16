require "spec_helper"

java_import 'org.eclipse.swt.graphics.Font'
java_import 'org.eclipse.swt.graphics.FontData'

module Glimmer
  describe "Glimmer Color" do
    include Glimmer

    before do
      @rspec_display_method = method(:display)
      self.class.send(:undef_method, :display)
      dsl :swt
    end

    after do
      @target.display.dispose if @target.display
      self.class.send(:define_method, :display, @rspec_display_method)
    end

    it "tests label with specified font name, height, and style" do
      @target = shell {
        @label = label {
          font name: 'Arial', height: 36, style: :normal
        }
      }

      font_data = @label.widget.getFont.getFontData
      font_datum = font_data.first
      expect(font_datum.getName).to eq('Arial')
      expect(font_datum.getHeight).to eq(36)
      expect(font_datum.getStyle).to eq(GSWT[:normal])
    end

    it "tests label with specified font styles (multiple)" do
      @target = shell {
        @label = label {
          font style: [:bold, :italic]
        }
      }

      font_data = @label.widget.getFont.getFontData
      font_datum = font_data.first
      expect(font_datum.getStyle).to eq(GSWT[:bold, :italic])
    end

    it "tests label with specified font style as SWT constant" do
      @target = shell {
        @label = label {
          font style: GSWT[:bold]
        }
      }

      font_data = @label.widget.getFont.getFontData
      font_datum = font_data.first
      expect(font_datum.getStyle).to eq(GSWT[:bold])
    end

    it "tests label with specified font as SWT object" do
      @display = display
      font_datum = FontData.new('Arial', 36, GSWT[:normal])
      @font = Font.new(@display.display, font_datum);
      @target = shell {
        @label = label {
          font @font
        }
      }

      font_data = @label.widget.getFont.getFontData
      font_datum = font_data.first
      expect(font_datum.getName).to eq('Arial')
      expect(font_datum.getHeight).to eq(36)
      expect(font_datum.getStyle).to eq(GSWT[:normal])
    end
  end
end
