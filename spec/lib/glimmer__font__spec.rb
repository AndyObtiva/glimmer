require "spec_helper"

java_import 'org.eclipse.swt.graphics.Font'
java_import 'org.eclipse.swt.graphics.FontData'

describe "Glimmer Color" do
  include Glimmer

  before do
    dsl :swt
  end

	after do
		@target.display.dispose if @target.display
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
    expect(font_datum.getStyle).to eq(RSwt[:normal])
  end

  it "tests label with specified font styles (multiple)" do
    @target = shell {
      @label = label {
        font style: [:bold, :italic]
      }
    }

    font_data = @label.widget.getFont.getFontData
    font_datum = font_data.first
    expect(font_datum.getStyle).to eq(RSwt[:bold, :italic])
  end

  it "tests label with specified font style as SWT constant" do
    @target = shell {
      @label = label {
        font style: RSwt[:bold]
      }
    }

    font_data = @label.widget.getFont.getFontData
    font_datum = font_data.first
    expect(font_datum.getStyle).to eq(RSwt[:bold])
  end

  it "tests label with specified font as SWT object" do
    @target = shell
    display = @target.display
    font_datum = FontData.new('Arial', 36, RSwt[:normal])
    @font = Font.new(display, font_datum);
    add_contents(@target) {
      @label = label {
        font @font
      }
    }

    font_data = @label.widget.getFont.getFontData
    font_datum = font_data.first
    expect(font_datum.getName).to eq('Arial')
    expect(font_datum.getHeight).to eq(36)
    expect(font_datum.getStyle).to eq(RSwt[:normal])
  end
end
