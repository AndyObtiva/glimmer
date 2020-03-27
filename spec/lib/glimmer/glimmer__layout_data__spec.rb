require "spec_helper"

# java_import 'org.eclipse.swt.layout.FillLayout'
# java_import 'org.eclipse.swt.layout.RowLayout'
# java_import 'org.eclipse.swt.layout.GridLayout'
java_import 'org.eclipse.swt.graphics.Point'

module Glimmer
  describe "Glimmer Layout Data" do
    include Glimmer

    before(:all) do
      class ::RedLabel
        include Glimmer::SWT::CustomWidget

        def body
          label(swt_style) {
            background :red
          }
        end
      end
    end

    after(:all) do
      Object.send(:remove_const, :RedLabel) if Object.const_defined?(:RedLabel)
    end

    before do
      dsl :swt
    end

    after do
      @target.display.dispose if @target.display
    end

    describe 'RowData' do
      it "sets RowData with all properties specified via property methods" do
        @target = shell {
          composite {
            row_layout(:horizontal)
            @label = label {
              layout_data {
                exclude true
                width 50
                height 30
              }
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(RowData)).to eq(true)
        expect(layout_data.exclude).to eq(true)
        expect(layout_data.width).to eq(50)
        expect(layout_data.height).to eq(30)
      end

      it "sets RowData with width/height constructor arguments" do
        @target = shell {
          composite {
            row_layout(:horizontal)
            @label = label {
              layout_data 50, 30
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(RowData)).to eq(true)
        expect(layout_data.height).to eq(30)
        expect(layout_data.width).to eq(50)
      end

      it "sets RowData with Point constructor argument" do
        @point = Point.new(50, 30)
        @target = shell {
          composite {
            row_layout(:horizontal)
            @label = label {
              layout_data @point
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(RowData)).to eq(true)
        expect(layout_data.height).to eq(30)
        expect(layout_data.width).to eq(50)
      end

      it "sets RowData explicitly" do
        @point = Point.new(50, 30)
        @target = shell {
          composite {
            row_layout(:horizontal)
            @label = label {
              layout_data RowData.new(50, 30)
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(RowData)).to eq(true)
        expect(layout_data.height).to eq(30)
        expect(layout_data.width).to eq(50)
      end

      it "sets RowData on a custom widget" do
        @target = shell {
          composite {
            row_layout(:horizontal)
            @label = red_label {
              layout_data {
                exclude true
                width 50
                height 30
              }
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(RowData)).to eq(true)
        expect(layout_data.exclude).to eq(true)
        expect(layout_data.width).to eq(50)
        expect(layout_data.height).to eq(30)
      end
    end

    describe 'GridData' do
      it "sets RowData with all properties specified via property methods" do
        @target = shell {
          composite {
            # grid_layout # default layout
            @label = label {
              layout_data {
                exclude true
                width_hint 50
                height_hint 30
                grab_excess_horizontal_space true
                grab_excess_vertical_space false
              	horizontal_alignment :end
              	vertical_alignment :beginning
              	horizontal_indent 10
              	vertical_indent 20
              	horizontal_span 15
              	vertical_span 25
              	minimum_width 49
              	minimum_height 29
              }
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(GridData)).to eq(true)
        expect(layout_data.exclude).to eq(true)
        expect(layout_data.widthHint).to eq(50)
        expect(layout_data.heightHint).to eq(30)
        expect(layout_data.grabExcessHorizontalSpace).to eq(true)
        expect(layout_data.grabExcessVerticalSpace).to eq(false)
        expect(layout_data.horizontalAlignment).to eq(GSWT[:end])
        expect(layout_data.verticalAlignment).to eq(GSWT[:beginning])
        expect(layout_data.horizontalIndent).to eq(10)
        expect(layout_data.verticalIndent).to eq(20)
        expect(layout_data.horizontalSpan).to eq(15)
        expect(layout_data.verticalSpan).to eq(25)
        expect(layout_data.minimumWidth).to eq(49)
        expect(layout_data.minimumHeight).to eq(29)
      end

      it "sets GridData with width/height constructor arguments" do
        @target = shell {
          composite {
            # grid_layout # default layout
            @label = label {
              layout_data 50, 30
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(GridData)).to eq(true)
        expect(layout_data.widthHint).to eq(50)
        expect(layout_data.heightHint).to eq(30)
      end

      it "sets GridData with 4 constructor arguments" do
        @target = shell {
          composite {
            # grid_layout # default layout
            @label = label {
              layout_data :fill, :end, true, false
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(GridData)).to eq(true)
        expect(layout_data.grabExcessHorizontalSpace).to eq(true)
        expect(layout_data.grabExcessVerticalSpace).to eq(false)
        expect(layout_data.horizontalAlignment).to eq(GSWT[:fill])
        expect(layout_data.verticalAlignment).to eq(GSWT[:end])
      end

      it "sets GridData with 6 constructor arguments" do
        @target = shell {
          composite {
            # grid_layout # default layout
            @label = label {
              layout_data GSWT[:fill], GSWT[:end], true, false, 15, 25
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(GridData)).to eq(true)
        expect(layout_data.grabExcessHorizontalSpace).to eq(true)
        expect(layout_data.grabExcessVerticalSpace).to eq(false)
        expect(layout_data.horizontalAlignment).to eq(GSWT[:fill])
        expect(layout_data.verticalAlignment).to eq(GSWT[:end])
        expect(layout_data.horizontalSpan).to eq(15)
        expect(layout_data.verticalSpan).to eq(25)
      end

      it "sets GridData explicitly" do
        @target = shell {
          composite {
            # grid_layout # default layout
            @label = label {
              layout_data GridData.new(GSWT[:fill], GSWT[:end], true, false)
            }
          }
        }

        widget = @label.widget
        layout_data = widget.getLayoutData
        expect(layout_data.is_a?(GridData)).to eq(true)
        expect(layout_data.grabExcessHorizontalSpace).to eq(true)
        expect(layout_data.grabExcessVerticalSpace).to eq(false)
        expect(layout_data.horizontalAlignment).to eq(GSWT[:fill])
        expect(layout_data.verticalAlignment).to eq(GSWT[:end])
      end
    end
  end
end
