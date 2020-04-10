require "spec_helper"

module GlimmerSpec
  describe Glimmer::UI::CustomWidget do
    include Glimmer

    before(:all) do
      class ::RedLabel
        include Glimmer::UI::CustomWidget

        body {
          label(swt_style) {
            background :red
          }
        }
      end

      class ::ColoredLabel
        include Glimmer::UI::CustomWidget

        body {
          label(swt_style) {
            background options[:color]
          }
        }
      end

      class ::MultiColorLabel
        include Glimmer::UI::CustomWidget

        options :color1, :color2
        options "font1", "font2"

        def text=(value)
          half_size = value.size/2
          @label1.swt_widget.setText value[0...half_size]
          @label2.swt_widget.setText value[half_size...value.size]
        end

        def text
          value1 = @label1.swt_widget.getText
          value2 = @label2.swt_widget.getText
          "#{value1}#{value2}"
        end

        body {
          composite {
            fill_layout :horizontal
            @label1 = label(swt_style) {
              background color1
              font font1
            }
            @label2 = label(swt_style) {
              background color2
              font font2
            }
          }
        }
      end

      module Red
        class Composite
          include Glimmer::UI::CustomWidget

          body {
            composite(swt_style) {
              background :red
            }
          }
        end

        class Label
          include Glimmer::UI::CustomWidget

          body {
            label(swt_style) {
              background :red
            }
          }
        end
      end

      class Sandwich
        include Glimmer::UI::CustomWidget

        body {
          composite(swt_style) {
            fill_layout :vertical
            background :white
            label {
              text 'SANDWICH TOP'
            }
            content.call
            label {
              text 'SANDWICH BOTTOM'
            }
          }
        }
      end

      class ::BeforeAndAfter
        include Glimmer::UI::CustomWidget

        before_body {
          @background = :red
        }

        after_body {
          @label.swt_widget.setText "Before and After"
        }

        body {
          composite {
            background @background
            @label = label {
              background @background
              foreground @foreground
            }
          }
        }

        after_body {
          @label.swt_widget.setEnabled(false)
        }

        before_body {
          @foreground = :green
        }
      end

      class ::InvalidCustomWidget
        include Glimmer::UI::CustomWidget
      end
    end

    after(:all) do
      Object.send(:remove_const, :InvalidCustomWidget) if Object.const_defined?(:InvalidCustomWidget)
      Object.send(:remove_const, :RedLabel) if Object.const_defined?(:RedLabel)
      Object.send(:remove_const, :ColoredLabel) if Object.const_defined?(:ColoredLabel)
      Object.send(:remove_const, :MultiColorLabel) if Object.const_defined?(:MultiColorLabel)
      GlimmerSpec::Red.send(:remove_const, :Composite) if GlimmerSpec::Red.const_defined?(:Composite)
      GlimmerSpec::Red.send(:remove_const, :Label) if GlimmerSpec::Red.const_defined?(:Label)
      GlimmerSpec.send(:remove_const, :Red) if GlimmerSpec.const_defined?(:Red)
      GlimmerSpec.send(:remove_const, :Sandwich) if GlimmerSpec.const_defined?(:Sandwich)
    end

    after do
      @target.dispose if @target
    end

    it "builds custom widget with no namespace" do
      @target = shell {
        @red_label = red_label
      }

      expect(@red_label.swt_widget.getParent).to eq(@target.swt_widget)
      expect(@red_label.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
    end

    it "builds custom widget with no namespace having attributes" do
      @target = shell {
        @red_label = red_label {
          text 'Red Label'
        }
      }

      expect(@red_label.swt_widget.getParent).to eq(@target.swt_widget)
      expect(@red_label.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@red_label.swt_widget.getText).to eq('Red Label')
    end

    it "builds custom widget with an option" do
      @target = shell {
        @colored_label = colored_label(color: :blue)
      }

      expect(@colored_label.swt_widget.getParent).to eq(@target.swt_widget)
      expect(@colored_label.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:blue).swt_color)
    end

    it "builds custom widget with namespace" do
      @target = shell {
        @red_label = glimmer_spec__red__label {
          text 'Red Label'
        }
      }

      expect(@red_label.swt_widget.getParent).to eq(@target.swt_widget)
      expect(@red_label.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@red_label.swt_widget.getText).to eq('Red Label')
    end

    it "builds custom widget with namespace and content" do
      @target = shell {
        @sandwich = glimmer_spec__sandwich {
          label {
            text 'SANDWICH CONTENT'
          }
        }
      }

      expect(@sandwich.swt_widget.getParent).to eq(@target.swt_widget)
      expect(@sandwich.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:white).swt_color)
      expect(@sandwich.swt_widget.getChildren.size).to eq(3)
      expect(@sandwich.swt_widget.getChildren[0].getText).to eq('SANDWICH TOP')
      expect(@sandwich.swt_widget.getChildren[1].getText).to eq('SANDWICH CONTENT')
      expect(@sandwich.swt_widget.getChildren[2].getText).to eq('SANDWICH BOTTOM')
    end

    it "builds nested custom widgets" do
      @target = shell {
        @red_composite = glimmer_spec__red__composite {
          row_layout :vertical
          @red_label = glimmer_spec__red__label {
            text 'Red Label'
          }
        }
      }

      expect(@red_composite.swt_widget.getParent).to eq(@target.swt_widget)
      expect(@red_composite.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@red_composite.swt_widget.getLayout.is_a?(RowLayout)).to be_truthy
      expect(@red_label.swt_widget.getParent).to eq(@red_composite.swt_widget)
      expect(@red_label.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@red_label.swt_widget.getText).to eq('Red Label')
    end

    it "builds composite custom widgets having options" do
      @target = shell {
        @multi_color_label = multi_color_label(
          :center,
          color1: :red,
          color2: :blue,
          font1: {height: 62},
          font2: {height: 73}
          ) {
          text 'Hello,World!'
        }
      }

      expect(@multi_color_label.swt_widget.getParent).to eq(@target.swt_widget)
      expect(@multi_color_label.swt_widget.getChildren.size).to eq(2)
      expect(@multi_color_label.swt_widget.getChildren[0]).to be_a(Label)
      expect(@multi_color_label.swt_widget.getChildren[0].getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@multi_color_label.swt_widget.getChildren[0].getFont.getFontData[0].getHeight).to eq(62)
      expect(@multi_color_label.swt_widget.getChildren[0].getText).to eq("Hello,")
      expect(@multi_color_label.swt_widget.getChildren[0].getStyle & Glimmer::SWT::SWTProxy[:center]).to eq(Glimmer::SWT::SWTProxy[:center])
      expect(@multi_color_label.swt_widget.getChildren[1]).to be_a(Label)
      expect(@multi_color_label.swt_widget.getChildren[1].getBackground).to eq(Glimmer::SWT::ColorProxy.new(:blue).swt_color)
      expect(@multi_color_label.swt_widget.getChildren[1].getFont.getFontData[0].getHeight).to eq(73)
      expect(@multi_color_label.swt_widget.getChildren[1].getText).to eq("World!")
      expect(@multi_color_label.swt_widget.getChildren[1].getStyle & Glimmer::SWT::SWTProxy[:center]).to eq(Glimmer::SWT::SWTProxy[:center])
    end

    it 'observes custom widget custom property' do
      @target = shell {
        @multi_color_label = multi_color_label(
          :center,
          color1: :red,
          color2: :blue,
          font1: {height: 62},
          font2: {height: 73}
          ) {
          text 'Hello,World!'
          on_updated_text {
            @updated_text = true
          }
        }
      }

      expect(@updated_text).to be_nil

      @multi_color_label.text = 'Howdy,Partner!'

      expect(@updated_text).to eq(true)
    end

    it 'observes custom widget custom property with alternative syntax' do
      @target = shell {
        @multi_color_label = multi_color_label(
          :center,
          color1: :red,
          color2: :blue,
          font1: {height: 62},
          font2: {height: 73}
          ) {
          text 'Hello,World!'
        }
      }

      @multi_color_label.on_updated_text {
        @updated_text_with_alternative_syntax = true
      }

      expect(@updated_text_with_alternative_syntax).to be_nil

      @multi_color_label.text = 'Howdy,Partner!'

      expect(@updated_text_with_alternative_syntax).to eq(true)
    end

    it 'executes before_body and after_body blocks' do
      @target = shell {
        @before_and_after = before_and_after
      }
      expect(@before_and_after.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      @label = @before_and_after.swt_widget.getChildren.first
      expect(@label.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@label.getForeground).to eq(Glimmer::SWT::ColorProxy.new(:green).swt_color)
      expect(@label.getText).to eq('Before and After')
      expect(@label.isEnabled).to eq(false)
    end

    it 'adds content' do
      @target = shell {
        @red_composite = glimmer_spec__red__composite
      }

      @red_composite.content {
        @text = text {
          text "Howdy"
        }
      }

      expect(@red_composite.swt_widget.getChildren.first).to eq(@text.swt_widget)
      expect(@text.swt_widget.getText).to eq('Howdy')
    end

    it 'returns Glimmer error if custom widget has no body in its definition' do
      @target = shell {
        expect {invalid_custom_widget}.to raise_error(Glimmer::Error)
      }
    end

    context 'UI code execution' do
      after do
        if @target
          @target.async_exec do
            @target.dispose
          end
          @target.start_event_loop
        end
      end

      it "syncronously and asynchronously executes UI code" do
        @target = shell {
          @red_label = red_label {
            text "text1"
          }
        }

        @red_label.async_exec do
          expect(@red_label.swt_widget.getText).to eq("text2")
        end

        # This takes prioerity over async_exec
        @red_label.sync_exec do
          @red_label.swt_widget.setText("text2")
        end
      end
    end
  end
end
