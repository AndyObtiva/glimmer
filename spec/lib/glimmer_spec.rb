require "spec_helper"

describe Glimmer do
  include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'
	include_package 'org.eclipse.swt.graphics'

  Shell = org.eclipse.swt.widgets.Shell unless Object.const_defined?(:Shell)
  Composite = org.eclipse.swt.widgets.Composite unless Object.const_defined?(:Composite)
  Text = org.eclipse.swt.widgets.Text unless Object.const_defined?(:Text)
  Spinner = org.eclipse.swt.widgets.Spinner unless Object.const_defined?(:Spinner)
  List = org.eclipse.swt.widgets.List unless Object.const_defined?(:List)
  Button = org.eclipse.swt.widgets.Button unless Object.const_defined?(:Button)
  Group = org.eclipse.swt.widgets.Group unless Object.const_defined?(:Group)

  GridLayout = org.eclipse.swt.layout.GridLayout unless Object.const_defined?(:GridLayout)
  FillLayout = org.eclipse.swt.layout.FillLayout unless Object.const_defined?(:FillLayout)
  RowLayout = org.eclipse.swt.layout.RowLayout unless Object.const_defined?(:RowLayout)

  Rectangle = org.eclipse.swt.graphics.Rectangle unless Object.const_defined?(:Rectangle)
  Point = org.eclipse.swt.graphics.Point unless Object.const_defined?(:Point)

  before do
    @target = nil
    dsl :swt
  end

	after do
		@target.display.dispose if @target.display
	end

  it "tests shell_with_default_layout" do
    @target = shell

    expect(@target).to_not be_nil
    expect(@target.widget).to_not be_nil
    expect(@target.widget).to be_instance_of(Shell)
    expect(@target.widget.getLayout).to_not be_nil
    expect(@target.widget.getLayout).to be_instance_of(FillLayout)
  end

  it "tests shell_with_title_and_layout" do
    shell_layout = GridLayout.new
    @target = shell {
      text "Title"
      layout shell_layout
    }

    expect(@target.widget.getText).to eq( "Title")
    expect(@target.widget.getLayout).to eq( shell_layout)
  end

  it "tests shell_with_bounds" do
    @target = shell {
      bounds 50, 75, 800, 600
    }

    expect(@target.widget.getBounds).to eq( Rectangle.new(50, 75, 800, 600) )
  end

  it "tests shell_with_size" do
    @target = shell {
      size 800, 600
    }

    expect(@target.widget.getSize).to eq( Point.new(800, 600) )
  end

  it "tests shell_and_composite_with_default_style_and_layout" do
    @target = shell {
      composite
    }

    expect(@target.widget.children.size).to eq( 1)
    expect(@target.widget.children[0]).to be_instance_of(Composite)
    composite_widget = @target.widget.children[0]
    expect(composite_widget).to have_style(:none)
    expect(composite_widget.getLayout).to be_instance_of(GridLayout)
    grid_layout = composite_widget.getLayout
    expect(grid_layout.numColumns).to eq( 1)
    expect(grid_layout.makeColumnsEqualWidth).to eq( false)
  end

  it "tests shell_and_group_with_default_style_and_layout" do
    @target = shell {
      group {
        text "Title"
      }
    }

    expect(@target.widget.children.size).to eq( 1)
    expect(@target.widget.children[0]).to be_instance_of(Java::OrgEclipseSwtWidgets::Group)
    group_widget = @target.widget.children[0]
    expect(group_widget).to have_style(:none)
    expect(group_widget.getLayout).to be_instance_of(GridLayout)
    grid_layout = group_widget.getLayout
    expect(grid_layout.numColumns).to eq( 1)
    expect(grid_layout.makeColumnsEqualWidth).to eq( false)
    expect(group_widget.getText).to eq( "Title")
  end

  it "tests shell_and_composite_with_style_and_layout" do
    composite_layout = RowLayout.new
    @target = shell {
      composite(:no_focus) {
        layout composite_layout
      }
    }

    expect(@target.widget.children.size).to eq( 1)
    expect(@target.widget.children[0]).to be_instance_of(Composite)
    composite_widget = @target.widget.children[0]
    expect(composite_widget).to have_style(:no_focus)
    expect(composite_widget.getLayout).to eq( composite_layout)
  end

  it "tests shell_and_composite_and_text_with_default_style" do
    @target = shell {
      composite {
        text
      }
    }

    composite_widget = @target.widget.children[0]
    expect(composite_widget.children.size).to eq( 1)
    expect(composite_widget.children[0]).to be_instance_of(Text)
    text_widget = composite_widget.children[0]
    expect(text_widget).to have_style(:border)
  end

  it "tests shell_and_composite_with_custom_layout_and_text_with_default_style" do
    composite_layout = RowLayout.new
    @target = shell {
      composite {
        text
        layout composite_layout
      }
    }

    composite_widget = @target.widget.children[0]
    expect(composite_widget.getLayout).to eq( composite_layout)
    expect(composite_widget.children.size).to eq( 1)
    expect(composite_widget.children[0]).to be_instance_of(Text)
    text_widget = composite_widget.children[0]
    expect(text_widget).to have_style(:border)
  end

  it "tests shell_and_composite_and_text_with_style_and_text" do
    @target = shell {
      composite {
        text(:password) {
          text "Hello"
        }
      }
    }

    composite_widget = @target.widget.children[0]
    expect(composite_widget.children.size).to eq( 1)
    expect(composite_widget.children[0]).to be_instance_of(Text)
    text_widget = composite_widget.children[0]
    expect(text_widget).to have_style(:password)
    expect(text_widget.getText).to eq( "Hello")
  end

  it "tests shell_and_spinner_default" do
    @target = shell {
      @spinner = spinner {
        selection 55
      }
    }

    expect(@spinner.widget).to be_instance_of(Spinner)
    expect(@spinner.widget).to have_style(:border)
    expect(@spinner.widget.getSelection).to eq( 55)
  end

  it "tests shell_and_list_default" do
    @target = shell {
      @list = list {
      }
    }

    expect(@list.widget).to be_instance_of(List)
    expect(@list.widget).to have_style(:border)
    expect(@list.widget).to have_style(:single)
    expect(@list.widget).to have_style(:v_scroll)
  end

  it "tests shell_and_button_default" do
    @target = shell {
      @button = button {
        text "Push Me"
      }
    }

    expect(@button.widget).to be_instance_of(Button)
    expect(@button.widget).to have_style(:push)
    expect(@button.widget.text).to eq( "Push Me")
  end

  it "tests shell_and_table_and_table_column_defaults" do
    @target = shell {
      @table = table {
        @table_column = table_column
      }
    }

    expect(@table.widget).to have_style(:border)
    assert @table.widget.getHeaderVisible
    assert @table.widget.getLinesVisible
    expect(@table_column.widget.getWidth).to eq( 80)
  end

  it "tests shell_containing_undefined_command" do
    @target = shell {
      undefined_command(:undefined_parameter) {
      }
    }

    expect(@target).to_not be_nil
    expect(@target.widget).to_not be_nil
    expect(@target.widget).to be_instance_of(Shell)
    expect(@target.widget.getLayout).to_not be_nil
    expect(@target.widget.getLayout).to be_instance_of(FillLayout)
  end


  it "tests add_contents" do
    @target = shell {
    }

    add_contents(@target) {
      composite {
        text(:password) {
          text "Hello"
        }
      }
    }

    composite_widget = @target.widget.children[0]
    expect(composite_widget.children.size).to eq( 1)
    expect(composite_widget.children[0]).to be_instance_of(Text)
    text_widget = composite_widget.children[0]
    expect(text_widget).to have_style(:password)
    expect(text_widget.getText).to eq( "Hello")
  end

end
