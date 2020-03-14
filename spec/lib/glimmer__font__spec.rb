require "spec_helper"

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
    expect(font_datum.getStyle).to eq(org.eclipse.swt.SWT::NORMAL)
  end

  it "tests label with specified font styles (multiple)" do
    @target = shell {
      @label = label {
        font style: [:bold, :italic]
      }
    }

    font_data = @label.widget.getFont.getFontData
    font_datum = font_data.first
    expect(font_datum.getStyle).to eq(org.eclipse.swt.SWT::BOLD | org.eclipse.swt.SWT::ITALIC)
  end
end
