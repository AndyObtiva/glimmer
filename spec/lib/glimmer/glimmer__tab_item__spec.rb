require "spec_helper"

java_import 'org.eclipse.swt.widgets.Composite'
java_import 'org.eclipse.swt.layout.GridLayout'
java_import 'org.eclipse.swt.layout.FillLayout'


describe "Glimmer Tab Item" do
  include Glimmer

  before(:all) do
    class ::RedTabFolder
      include Glimmer::SWT::CustomWidget

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
    @target.display.dispose if @target.display
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
    expect(@target.widget).to_not be_nil
    expect(@tab_folder.widget.items.size).to eq(1)
    expect(@tab_item_composite.widget).to be_instance_of(Composite)
    expect(@tab_folder.widget.items[0].control).to eq(@tab_item_composite.widget)
    expect(@tab_item_composite.tab_item.widget.text).to eq("Tab 1")
    expect(@tab_item_composite.widget.getLayout).to_not be_nil
    expect(@tab_item_composite.widget.getLayout).to be_instance_of(GridLayout)
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
    expect(@target.widget).to_not be_nil
    expect(@tab_folder.widget.items.size).to eq(1)
    expect(@tab_item_composite.widget).to be_instance_of(Composite)
    expect(@tab_folder.widget.items[0].control).to eq(@tab_item_composite.widget)
    expect(@tab_item_composite.tab_item.widget.text).to eq("Tab 2")
    expect(@tab_item_composite.widget.getLayout).to_not be_nil
    expect(@tab_item_composite.widget.getLayout).to be_instance_of(FillLayout)
  end

  it "builds custom widget tab" do
    @target = shell {
      @tab_folder = red_tab_folder {
        @tab_item_composite = tab_item {
          text "Tab 1"
        }
      }
    }

    expect(@tab_folder.widget.items.size).to eq(1)
    expect(@tab_folder.widget.getBackground).to eq(GColor.color_for(:red))
    expect(@tab_item_composite.widget).to be_instance_of(Composite)
    expect(@tab_folder.widget.items[0].control).to eq(@tab_item_composite.widget)
    expect(@tab_item_composite.tab_item.widget.text).to eq("Tab 1")
    expect(@tab_item_composite.widget.getLayout).to_not be_nil
    expect(@tab_item_composite.widget.getLayout).to be_instance_of(GridLayout)
  end

end
