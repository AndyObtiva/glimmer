require "spec_helper"

module GlimmerSpec
  describe "Glimmer Layout" do
    include Glimmer

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

        widget = @composite.swt_widget
        layout = widget.getLayout
        expect(layout.is_a?(FillLayout)).to eq(true)
        expect(layout.type).to eq(Glimmer::SWT::SWTProxy[:horizontal])
        expect(layout.marginWidth).to eq(30)
        expect(layout.marginHeight).to eq(50)
        expect(layout.spacing).to eq(5)
      end

      it "sets FillLayout with one SWT constructor argument" do
        @target = shell {
          @composite = composite {
            fill_layout(:horizontal)
          }
        }

        widget = @composite.swt_widget
        layout = widget.getLayout
        expect(layout.is_a?(FillLayout)).to eq(true)
        expect(layout.type).to eq(Glimmer::SWT::SWTProxy[:horizontal])
      end
    end

    describe 'RowLayout' do
      it "sets RowLayout with all properties specified via property methods" do
        @target = shell {
          @composite = composite {
            row_layout {
              wrap true
              pack false
              justify true
              type :vertical
              margin_left 1
              margin_top 2
              margin_right 3
              margin_bottom 4
              spacing 5
            }
          }
        }

        widget = @composite.swt_widget
        layout = widget.getLayout
        expect(layout.is_a?(RowLayout)).to eq(true)
        expect(layout.wrap).to eq(true)
        expect(layout.pack).to eq(false)
        expect(layout.justify).to eq(true)
        expect(layout.type).to eq(Glimmer::SWT::SWTProxy[:vertical])
        expect(layout.marginLeft).to eq(1)
        expect(layout.marginTop).to eq(2)
        expect(layout.marginRight).to eq(3)
        expect(layout.marginBottom).to eq(4)
        expect(layout.spacing).to eq(5)
      end

      it "sets RowLayout with one SWT constructor argument" do
        @target = shell {
          @composite = composite {
            row_layout :horizontal
          }
        }

        widget = @composite.swt_widget
        layout = widget.getLayout
        expect(layout.is_a?(RowLayout)).to eq(true)
        expect(layout.type).to eq(Glimmer::SWT::SWTProxy[:horizontal])
      end
    end

    describe 'GridLayout' do
      it "sets GridLayout with all properties specified via property methods" do
        @target = shell {
          @composite = composite {
            grid_layout {
              make_columns_equal_width true
              num_columns 8
              margin_left 1
              margin_top 2
              margin_right 3
              margin_bottom 4
              margin_width 30
              margin_height 50
              horizontal_spacing 4
              vertical_spacing 5
            }
          }
        }

        widget = @composite.swt_widget
        layout = widget.getLayout
        expect(layout.is_a?(GridLayout)).to eq(true)
        expect(layout.makeColumnsEqualWidth).to eq(true)
        expect(layout.numColumns).to eq(8)
        expect(layout.marginLeft).to eq(1)
        expect(layout.marginTop).to eq(2)
        expect(layout.marginRight).to eq(3)
        expect(layout.marginBottom).to eq(4)
        expect(layout.marginWidth).to eq(30)
        expect(layout.marginHeight).to eq(50)
        expect(layout.horizontalSpacing).to eq(4)
        expect(layout.verticalSpacing).to eq(5)
      end

      it "sets GridLayout with one SWT constructor argument" do
        @target = shell {
          @composite = composite {
            grid_layout 8, true
          }
        }

        widget = @composite.swt_widget
        layout = widget.getLayout
        expect(layout.is_a?(GridLayout)).to eq(true)
        expect(layout.makeColumnsEqualWidth).to eq(true)
        expect(layout.numColumns).to eq(8)
      end
    end
  end
end
