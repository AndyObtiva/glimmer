require "spec_helper"

describe "Glimmer Tab Item" do
  include Glimmer

  before do
    dsl :swt
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
    expect(@tab_item_composite.widget).to be_instance_of(org.eclipse.swt.widgets.Composite)
    expect(@tab_folder.widget.items[0].control).to eq(@tab_item_composite.widget)
    expect(@tab_item_composite.tab_item.widget.text).to eq("Tab 1")
    expect(@tab_item_composite.widget.getLayout).to_not be_nil
    expect(@tab_item_composite.widget.getLayout).to be_instance_of(org.eclipse.swt.layout.GridLayout)
  end

  it "tests tab item composite with fill layout" do
    @target = shell {
      @tab_folder = tab_folder {
        @tab_item_composite = tab_item {
          text "Tab 2"
          layout org.eclipse.swt.layout.FillLayout.new
          label {text "Hello"}
        }
      }
    }

    expect(@target).to_not be_nil
    expect(@target.widget).to_not be_nil
    expect(@tab_folder.widget.items.size).to eq(1)
    expect(@tab_item_composite.widget).to be_instance_of(org.eclipse.swt.widgets.Composite)
    expect(@tab_folder.widget.items[0].control).to eq(@tab_item_composite.widget)
    expect(@tab_item_composite.tab_item.widget.text).to eq("Tab 2")
    expect(@tab_item_composite.widget.getLayout).to_not be_nil
    expect(@tab_item_composite.widget.getLayout).to be_instance_of(org.eclipse.swt.layout.FillLayout)
  end

end
