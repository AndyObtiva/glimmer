require "spec_helper"

module GlimmerSpec
  describe "Glimmer Tab Item" do
    include Glimmer

    before(:all) do
      class ::RedTabFolder
        include Glimmer::UI::CustomWidget

        def body
          tab_folder {
            background :red
          }
        end
      end
    end

    after(:all) do
      Object.send(:remove_const, :RedTabFolder) if Object.const_defined?(:RedTabFolder)
    end

    after do
      @target.dispose if @target
    end

    it "tests tab item composite with default layout" do
      @target = shell {
        @tab_folder = tab_folder {
          @tab_item_composite = tab_item {
            text "Tab 1"
            label {text "Hello"}
          }
        }
      }

      expect(@target).to_not be_nil
      expect(@target.swt_widget).to_not be_nil
      expect(@tab_folder.swt_widget.items.size).to eq(1)
      expect(@tab_item_composite.swt_widget).to be_instance_of(Composite)
      expect(@tab_folder.swt_widget.items[0].control).to eq(@tab_item_composite.swt_widget)
      expect(@tab_item_composite.swt_tab_item.getText).to eq("Tab 1")
      expect(@tab_item_composite.swt_widget.getLayout).to_not be_nil
      expect(@tab_item_composite.swt_widget.getLayout).to be_instance_of(GridLayout)
    end

    it "tests tab item composite with invalid parent (not a tab folder)" do
      @target = shell
      expect {
        @target.content {
          @invalid_parent = composite {
            @tab_item_composite = tab_item {
              text "Tab 1"
              label {text "Hello"}
            }
          }
        }
      }.to raise_error(StandardError)
    end

    it "tests tab item composite with fill layout" do
      @target = shell {
        @tab_folder = tab_folder {
          @tab_item_composite = tab_item {
            text "Tab 2"
            layout FillLayout.new
            label {text "Hello"}
          }
        }
      }

      expect(@target).to_not be_nil
      expect(@target.swt_widget).to_not be_nil
      expect(@tab_folder.swt_widget.items.size).to eq(1)
      expect(@tab_item_composite.swt_widget).to be_instance_of(Composite)
      expect(@tab_folder.swt_widget.items[0].control).to eq(@tab_item_composite.swt_widget)
      expect(@tab_item_composite.swt_tab_item.getText).to eq("Tab 2")
      expect(@tab_item_composite.swt_widget.getLayout).to_not be_nil
      expect(@tab_item_composite.swt_widget.getLayout).to be_instance_of(FillLayout)
    end

    it "builds custom widget tab" do
      @target = shell {
        @tab_folder = red_tab_folder {
          @tab_item_composite = tab_item {
            text "Tab 1"
          }
        }
      }

      expect(@tab_folder.swt_widget.items.size).to eq(1)
      expect(@tab_folder.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@tab_item_composite.swt_widget).to be_instance_of(Composite)
      expect(@tab_folder.swt_widget.items[0].control).to eq(@tab_item_composite.swt_widget)
      expect(@tab_item_composite.swt_tab_item.getText).to eq("Tab 1")
      expect(@tab_item_composite.swt_widget.getLayout).to_not be_nil
      expect(@tab_item_composite.swt_widget.getLayout).to be_instance_of(GridLayout)
    end
  end
end
