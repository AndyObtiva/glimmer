require "spec_helper"

module GlimmerSpec
  describe "Glimmer Color" do
    include Glimmer

    before do
      @rspec_display_method = method(:display)
      self.class.send(:undef_method, :display)
    end

    after do
      @target.dispose if @target
      self.class.send(:define_method, :display, @rspec_display_method)
    end

    it "tests label with specified font name, height, and style" do
      @target = shell {
        @label = label {
          font name: 'Arial', height: 36, style: :normal
        }
      }

      font_data = @label.swt_widget.getFont.getFontData
      font_datum = font_data.first
      expect(font_datum.getName).to eq('Arial')
      expect(font_datum.getHeight).to eq(36)
      expect(font_datum.getStyle).to eq(Glimmer::SWT::SWTProxy[:normal])
    end

    it "tests label with specified font styles (multiple)" do
      @target = shell {
        @label = label {
          font style: [:bold, :italic]
        }
      }

      font_data = @label.swt_widget.getFont.getFontData
      font_datum = font_data.first
      expect(font_datum.getStyle).to eq(Glimmer::SWT::SWTProxy[:bold, :italic])
    end

    it "fails with a friendly message when label is given an invalid font style" do
      @target = shell {
        label {
          expect {
            font style: :deco
          }.to raise_error("deco is an invalid font style! Valid values are :normal, :bold, and :italic")
        }
      }
    end

    it "tests label with specified font style as SWT constant" do
      @target = shell {
        @label = label {
          font style: Glimmer::SWT::SWTProxy[:bold]
        }
      }

      font_data = @label.swt_widget.getFont.getFontData
      font_datum = font_data.first
      expect(font_datum.getStyle).to eq(Glimmer::SWT::SWTProxy[:bold])
    end

    it "tests label with specified font as SWT object" do
      @display = display
      font_datum = FontData.new('Arial', 36, Glimmer::SWT::SWTProxy[:normal])
      @font = Font.new(@display.swt_display, font_datum);
      @target = shell {
        @label = label {
          font @font
        }
      }

      font_data = @label.swt_widget.getFont.getFontData
      font_datum = font_data.first
      expect(font_datum.getName).to eq('Arial')
      expect(font_datum.getHeight).to eq(36)
      expect(font_datum.getStyle).to eq(Glimmer::SWT::SWTProxy[:normal])
    end
  end
end
