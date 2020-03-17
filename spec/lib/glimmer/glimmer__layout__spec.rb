require "spec_helper"

java_import 'org.eclipse.swt.layout.FillLayout'

module Glimmer
  describe "Glimmer Layout" do
    include Glimmer

    before do
      dsl :swt
    end

    after do
      @target.display.dispose if @target.display
    end

    describe 'FillLayout' do
      it "sets FillLayout with all properties specified via property methods" do
        @target = shell {
          @composite = composite {
            fill_layout {
              type :horizontal
              margin_width 30
              margin_height 50
              spacing 5
            }
          }
        }

        widget = @composite.widget
        layout = widget.getLayout
        expect(layout.is_a?(FillLayout)).to eq(true)
        expect(layout.type).to eq(GSWT[:horizontal])
        expect(layout.marginWidth).to eq(30)
        expect(layout.marginHeight).to eq(50)
        expect(layout.spacing).to eq(5)
      end

    end
  end
end
