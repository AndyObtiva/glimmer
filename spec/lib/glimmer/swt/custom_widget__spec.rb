require "spec_helper"

module Glimmer
  module SWT
    describe CustomWidget do
      include Glimmer

      before(:all) do
        class ::RedLabel
          include CustomWidget
          def body
            label(swt_style) {
              background :red
            }
          end
        end

        class ::ColoredLabel
          include CustomWidget

          def body
            label(swt_style) {
              background options[:color]
            }
          end
        end

        class ::MultiColorLabel
          include CustomWidget

          options :color1, :color2
          options "font1", "font2"

          def text=(value)
            half_size = value.size/2
            @label1.widget.setText value[0...half_size]
            @label2.widget.setText value[half_size...value.size]
          end

          def text
            value1 = @label1.widget.getText
            value2 = @label2.widget.getText
            "#{value1}#{value2}"
          end

          def body
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
          end
        end

        module Red
          class Composite
            include CustomWidget

            def body
              composite(swt_style) {
                background :red
              }
            end
          end

          class Label
            include CustomWidget

            def body
              label(swt_style) {
                background :red
              }
            end
          end
        end

        class Sandwich
          include CustomWidget

          def body
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
          end
        end

        class ::BeforeAndAfter
          include CustomWidget

          before_body do
            @background = :red
          end

          after_body do
            @label.widget.setText "Before and After"
          end

          def body
            composite {
              background @background
              @label = label {
                background @background
                foreground @foreground
              }
            }
          end

          after_body do
            @label.widget.setEnabled(false)
          end

          before_body do
            @foreground = :green
          end
        end
      end

      after(:all) do
        Object.send(:remove_const, :RedLabel) if Object.const_defined?(:RedLabel)
        Object.send(:remove_const, :ColoredLabel) if Object.const_defined?(:ColoredLabel)
        Object.send(:remove_const, :MultiColorLabel) if Object.const_defined?(:MultiColorLabel)
        Glimmer::Red.send(:remove_const, :Composite) if Glimmer::Red.const_defined?(:Composite)
        Glimmer::Red.send(:remove_const, :Label) if Glimmer::Red.const_defined?(:Label)
        Glimmer.send(:remove_const, :Red) if Glimmer.const_defined?(:Red)
        Glimmer.send(:remove_const, :Sandwich) if Glimmer.const_defined?(:Sandwich)
      end

      before do
        @rspec_display_method = method(:display)
        self.class.send(:undef_method, :display)
        dsl :swt
      end

      after do
        @target.display.dispose if @target.display
        self.class.send(:define_method, :display, @rspec_display_method)
      end

      it "builds custom widget with no namespace" do
        @target = shell {
          @red_label = red_label
        }

        expect(@red_label.widget.getParent).to eq(@target.widget)
        expect(@red_label.widget.getBackground).to eq(GColor.color_for(:red))
      end

      it "builds custom widget with no namespace having attributes" do
        @target = shell {
          @red_label = red_label {
            text 'Red Label'
          }
        }

        expect(@red_label.widget.getParent).to eq(@target.widget)
        expect(@red_label.widget.getBackground).to eq(GColor.color_for(:red))
        expect(@red_label.widget.getText).to eq('Red Label')
      end

      it "builds custom widget with an option" do
        @target = shell {
          @colored_label = colored_label(color: :blue)
        }

        expect(@colored_label.widget.getParent).to eq(@target.widget)
        expect(@colored_label.widget.getBackground).to eq(GColor.color_for(:blue))
      end

      it "builds custom widget with namespace" do
        @target = shell {
          @red_label = glimmer__red__label {
            text 'Red Label'
          }
        }

        expect(@red_label.widget.getParent).to eq(@target.widget)
        expect(@red_label.widget.getBackground).to eq(GColor.color_for(:red))
        expect(@red_label.widget.getText).to eq('Red Label')
      end

      it "builds custom widget with namespace and content" do
        @target = shell {
          @sandwich = glimmer__sandwich {
            label {
              text 'SANDWICH CONTENT'
            }
          }
        }

        expect(@sandwich.widget.getParent).to eq(@target.widget)
        expect(@sandwich.widget.getBackground).to eq(GColor.color_for(:white))
        expect(@sandwich.widget.getChildren.size).to eq(3)
        expect(@sandwich.widget.getChildren[0].getText).to eq('SANDWICH TOP')
        expect(@sandwich.widget.getChildren[1].getText).to eq('SANDWICH CONTENT')
        expect(@sandwich.widget.getChildren[2].getText).to eq('SANDWICH BOTTOM')
      end

      it "builds nested custom widgets" do
        @target = shell {
          @red_composite = glimmer__red__composite {
            row_layout :vertical
            @red_label = glimmer__red__label {
              text 'Red Label'
            }
          }
        }

        expect(@red_composite.widget.getParent).to eq(@target.widget)
        expect(@red_composite.widget.getBackground).to eq(GColor.color_for(:red))
        expect(@red_composite.widget.getLayout.is_a?(RowLayout)).to be_truthy
        expect(@red_label.widget.getParent).to eq(@red_composite.widget)
        expect(@red_label.widget.getBackground).to eq(GColor.color_for(:red))
        expect(@red_label.widget.getText).to eq('Red Label')
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

        expect(@multi_color_label.widget.getParent).to eq(@target.widget)
        expect(@multi_color_label.widget.getChildren.size).to eq(2)
        expect(@multi_color_label.widget.getChildren[0]).to be_a(Label)
        expect(@multi_color_label.widget.getChildren[0].getBackground).to eq(GColor.color_for(:red))
        expect(@multi_color_label.widget.getChildren[0].getFont.getFontData[0].getHeight).to eq(62)
        expect(@multi_color_label.widget.getChildren[0].getText).to eq("Hello,")
        expect(@multi_color_label.widget.getChildren[0].getStyle & GSWT[:center]).to eq(GSWT[:center])
        expect(@multi_color_label.widget.getChildren[1]).to be_a(Label)
        expect(@multi_color_label.widget.getChildren[1].getBackground).to eq(GColor.color_for(:blue))
        expect(@multi_color_label.widget.getChildren[1].getFont.getFontData[0].getHeight).to eq(73)
        expect(@multi_color_label.widget.getChildren[1].getText).to eq("World!")
        expect(@multi_color_label.widget.getChildren[1].getStyle & GSWT[:center]).to eq(GSWT[:center])
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
        expect(@before_and_after.widget.getBackground).to eq(GColor.color_for(:red))
        @label = @before_and_after.widget.getChildren.first
        expect(@label.getBackground).to eq(GColor.color_for(:red))
        expect(@label.getForeground).to eq(GColor.color_for(:green))
        expect(@label.getText).to eq('Before and After')
        expect(@label.isEnabled).to eq(false)
      end

      it 'adds content' do
        @target = shell {
          @red_composite = red__composite
        }

        @red_composite.add_content {
          @text = text {
            text "Howdy"
          }
        }

        expect(@red_composite.widget.getChildren.first).to eq(@text.widget)
        expect(@text.widget.getText).to eq('Howdy')
      end

      context 'UI code execution' do
        after do
          @target.async_exec do
            @target.widget.dispose
          end
          @target.start_event_loop
        end

        it 'asyncronously executes UI code' do
          @target = shell {
            @red_label = red_label {
              text "text1"
            }
          }

          @red_label.async_exec do
            @red_label.widget.setText("text2")
          end

          expect(@red_label.widget.getText).to_not eq("text2")

          @red_label.async_exec do
            expect(@red_label.widget.getText).to eq("text2")
          end
        end

        it "syncronously executes UI code" do
          @target = shell {
            @red_label = red_label {
              text "text1"
            }
          }

          @red_label.async_exec do
            expect(@red_label.widget.getText).to eq("text2")
          end

          @red_label.sync_exec do
            @red_label.widget.setText("text2")
          end
        end
      end
    end
  end
end
