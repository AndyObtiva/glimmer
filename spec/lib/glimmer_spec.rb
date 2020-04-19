require "spec_helper"

module GlimmerSpec
  describe Glimmer do
    include Glimmer

    it "tests shell with no args having default layout and singleton display instance" do
      @target = shell

      expect(@target).to_not be_nil
      expect(@target.swt_widget).to_not be_nil
      expect(@target.swt_widget).to be_instance_of(Shell)
      expect(@target.swt_widget.getLayout).to_not be_nil
      expect(@target.swt_widget.getLayout).to be_instance_of(FillLayout)
      expect(@target.has_style?(:shell_trim)).to eq(true)
    end

    it "tests shell with one arg of unresizable style bit combination" do
      @target = shell(Glimmer::SWT::SWTProxy[:shell_trim] & (~Glimmer::SWT::SWTProxy[:resize]))

      expect(@target).to_not be_nil
      expect(@target.swt_widget).to_not be_nil
      expect(@target.swt_widget).to be_instance_of(Shell)
      expect(@target.has_style?(:close)).to eq(true)
      expect(@target.has_style?(:title)).to eq(true)
      expect(@target.has_style?(:min)).to eq(true)
      expect(@target.has_style?(:max)).to eq(true)
      expect(@target.has_style?(:resize)).to eq(false)
    end

    it "tests shell with one arg of convenience no_resize style bit" do
      @target = shell(:no_resize)

      expect(@target).to_not be_nil
      expect(@target.swt_widget).to_not be_nil
      expect(@target.swt_widget).to be_instance_of(Shell)
      expect(@target.has_style?(:close)).to eq(true)
      expect(@target.has_style?(:title)).to eq(true)
      expect(@target.has_style?(:min)).to eq(true)
      expect(@target.has_style?(:max)).to eq(false)
      expect(@target.has_style?(:resize)).to eq(false)
    end

    it "tests shell with multiple style bits" do
      @target = shell(:dialog_trim, :application_modal)

      expect(@target).to_not be_nil
      expect(@target.swt_widget).to_not be_nil
      expect(@target.swt_widget).to be_instance_of(Shell)
      expect(@target.has_style?(:dialog_trim)).to eq(true)
      expect(@target.has_style?(:application_modal)).to eq(true)
    end

    it "tests shell with one arg of display" do
      @display = Glimmer::SWT::DisplayProxy.instance.swt_display
      @target = shell(@display)

      expect(@target).to_not be_nil
      expect(@target.swt_widget).to_not be_nil
      expect(@target.swt_widget).to be_instance_of(Shell)
      expect(@target.swt_widget.getLayout).to_not be_nil
      expect(@target.swt_widget.getLayout).to be_instance_of(FillLayout)
      expect(@target.has_style?(:shell_trim)).to eq(true)
    end

    it "tests shell with two args of display and style bit" do
      @display = Glimmer::SWT::DisplayProxy.instance.swt_display
      @target = shell(@display, :title)

      expect(@target).to_not be_nil
      expect(@target.swt_widget).to_not be_nil
      expect(@target.swt_widget).to be_instance_of(Shell)
      expect(@target.swt_widget.getLayout).to_not be_nil
      expect(@target.swt_widget.getLayout).to be_instance_of(FillLayout)
      expect(@target.has_style?(:close)).to eq(false)
      expect(@target.has_style?(:title)).to eq(true)
      expect(@target.has_style?(:min)).to eq(false)
      expect(@target.has_style?(:max)).to eq(false)
      expect(@target.has_style?(:resize)).to eq(false)
    end

    it "tests shell with two args of display and multiple style bits" do
      @display = Glimmer::SWT::DisplayProxy.instance.swt_display
      @target = shell(@display, :dialog_trim, :application_modal)

      expect(@target).to_not be_nil
      expect(@target.swt_widget).to_not be_nil
      expect(@target.swt_widget).to be_instance_of(Shell)
      expect(@target.swt_widget.getLayout).to_not be_nil
      expect(@target.swt_widget.getLayout).to be_instance_of(FillLayout)
      expect(@target.has_style?(:dialog_trim)).to eq(true)
      expect(@target.has_style?(:application_modal)).to eq(true)
    end

    it "tests shell with one arg of parent shell" do
      @target = shell
      @dialog_shell = shell(@target.swt_widget)

      expect(@dialog_shell).to_not be_nil
      expect(@dialog_shell.swt_widget).to_not be_nil
      expect(@dialog_shell.swt_widget).to be_instance_of(Shell)
      expect(@dialog_shell.swt_widget.getLayout).to_not be_nil
      expect(@dialog_shell.swt_widget.getLayout).to be_instance_of(FillLayout)
      expect(@dialog_shell.has_style?(:dialog_trim)).to eq(true)
    end

    it "tests shell with two args of parent shell and style bit" do
      @target = shell
      @dialog_shell = shell(@target.swt_widget, :title)

      expect(@dialog_shell).to_not be_nil
      expect(@dialog_shell.swt_widget).to_not be_nil
      expect(@dialog_shell.swt_widget).to be_instance_of(Shell)
      expect(@dialog_shell.swt_widget.getLayout).to_not be_nil
      expect(@dialog_shell.swt_widget.getLayout).to be_instance_of(FillLayout)
      expect(@dialog_shell.has_style?(:dialog_trim)).to eq(false)
      expect(@dialog_shell.has_style?(:title)).to eq(true)
    end

    it "renders shell with title and layout" do
      shell_layout = GridLayout.new
      @target = shell {
        text "Title"
        layout shell_layout
      }

      expect(@target.swt_widget.getText).to eq( "Title")
      expect(@target.swt_widget.getLayout).to eq( shell_layout)
    end

    it "tests shell_with_bounds" do
      @target = shell {
        bounds 50, 75, 800, 600
      }

      expect(@target.swt_widget.getBounds).to eq( Rectangle.new(50, 75, 800, 600) )
    end

    it "tests shell_with_size" do
      @target = shell {
        size 800, 600
      }

      expect(@target.swt_widget.getSize).to eq( Point.new(800, 600) )
    end

    it "tests shell_and_composite_with_default_style_and_layout" do
      @target = shell {
        composite
      }

      expect(@target.swt_widget.children.size).to eq( 1)
      expect(@target.swt_widget.children[0]).to be_instance_of(Composite)
      composite_widget = @target.swt_widget.children[0]
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

      expect(@target.swt_widget.children.size).to eq( 1)
      expect(@target.swt_widget.children[0]).to be_instance_of(Java::OrgEclipseSwtWidgets::Group)
      group_widget = @target.swt_widget.children[0]
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

      expect(@target.swt_widget.children.size).to eq( 1)
      expect(@target.swt_widget.children[0]).to be_instance_of(Composite)
      composite_widget = @target.swt_widget.children[0]
      expect(composite_widget).to have_style(:no_focus)
      expect(composite_widget.getLayout).to eq( composite_layout)
    end

    it "tests shell_and_composite_and_text_with_default_style" do
      @target = shell {
        composite {
          text
        }
      }

      composite_widget = @target.swt_widget.children[0]
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

      composite_widget = @target.swt_widget.children[0]
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

      composite_widget = @target.swt_widget.children[0]
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

      expect(@spinner.swt_widget).to be_instance_of(Spinner)
      expect(@spinner.swt_widget).to have_style(:border)
      expect(@spinner.swt_widget.getSelection).to eq( 55)
    end

    it "tests shell_and_list_default" do
      @target = shell {
        @list = list {
        }
      }

      expect(@list.swt_widget).to be_instance_of(List)
      expect(@list.swt_widget).to have_style(:border)
      expect(@list.swt_widget).to have_style(:single)
      expect(@list.swt_widget).to have_style(:v_scroll)
    end

    it "tests shell_and_button_default" do
      @target = shell {
        @button = button {
          text "Push Me"
        }
      }

      expect(@button.swt_widget).to be_instance_of(Button)
      expect(@button.swt_widget).to have_style(:push)
      expect(@button.swt_widget.text).to eq( "Push Me")
    end

    it "tests shell and browser default" do
      @target = shell {
        @browser = browser {
          text <<~HTML
          <html>
          <head>
          </head>
          <body>
          <form>
          <input id="answer" value="42">
          </form>
          </body>
          </html>
          HTML
          on_completed {
            expect(@browser.swt_widget.evaluate("document.getElementById('answer').value")).to eq('42')
          }
        }
      }
      expect(@browser.swt_widget.is_a?(Browser)).to be_truthy
    end

    it "tests shell_and_table_and_table_column_defaults" do
      @target = shell {
        @table = table {
          @table_column = table_column
        }
      }

      expect(@table.swt_widget).to have_style(:border)
      expect(@table.swt_widget.getHeaderVisible).to eq(true)
      expect(@table.swt_widget.getLinesVisible).to eq(true)
      expect(@table_column.swt_widget.getWidth).to eq( 80)
    end

    it "tests shell_containing_undefined_command" do
      @target = shell {
        expect do
          undefined_command(:undefined_parameter) {
          }
        end.to raise_error(NoMethodError)
      }
    end


    it 'sets background image via image path' do
      @target = shell {
        @composite = composite {
          background_image File.expand_path(File.join(__FILE__, '..', '..', '..', 'images', 'glimmer-hello-world.png'))
        }
      }

      expect(@composite.swt_widget.getBackgroundImage.is_a?(Image)).to eq(true)
    end

    it 'sets background image via image object' do
      image_data = ImageData.new(File.expand_path(File.join(__FILE__, '..', '..', '..', 'images', 'glimmer-hello-world.png')))
      image = Image.new(display.swt_display, image_data)
      @target = shell {
        @composite = composite {
          background_image image
        }
      }

      expect(@composite.swt_widget.getBackgroundImage).to eq(image)
    end

    context 'focus' do
      after do
        if @target
          @target.async_exec do
            @target.dispose
          end
          @target.open
        end
      end

      it 'does not focus widget when not declaring focus true' do
        @target = shell {
          alpha 0 # keep invisible while running specs
          @text1 = text {
            text "First one is focused by default"
          }
          @text2 = text {
            text "Not focused"
          }
        }

        @target.async_exec do
          expect(@text1.swt_widget.isFocusControl).to eq(true)
          expect(@text2.swt_widget.isFocusControl).to eq(false)
        end
      end

      it 'does not focus widget when declaring focus false' do
        @target = shell {
          alpha 0 # keep invisible while running specs
          @text1 = text {
            text "First one is focused by default"
          }
          @text2 = text {
            focus false
            text "Not focused"
          }
        }

        @target.async_exec do
          expect(@text1.swt_widget.isFocusControl).to eq(true)
          expect(@text2.swt_widget.isFocusControl).to eq(false)
        end
      end

      it 'focuses widget when declaring focus true' do
        @target = shell {
          alpha 0 # keep invisible while running specs
          @text1 = text {
            text "Not focused"
          }
          @text2 = text {
            focus true
            text "Focused"
          }
        }

        @target.async_exec do
          expect(@text1.swt_widget.isFocusControl).to eq(false)
          expect(@text2.swt_widget.isFocusControl).to eq(true)
        end
      end
    end
  end
end
