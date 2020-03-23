require "spec_helper"

module Glimmer
  describe "Glimmer Custom Widget" do
    include Glimmer

    before do
      @rspec_display_method = method(:display)
      self.class.send(:undef_method, :display)
      dsl :swt
      class ::RedLabel
        include Glimmer::SWT::CustomWidget
        def body
          label(swt_style) {
            background :red
          }
        end
      end
      class ::ColoredLabel
        include Glimmer::SWT::CustomWidget
        def body
          label(swt_style) {
            background options[:color]
          }
        end
      end
      # class ::MultiColoredLabel
      #   include Glimmer::SWT::CustomWidget
      #   attr_option :color1, :color2
      #   def text=(value)
      #     half_size = value.size/2
      #     @label1.setText value[0...half_size]
      #     @label2.setText value[half_size...value.size]
      #   end
      #   def text
      #     value1 = @label1.getText
      #     value2 = @label2.getText
      #     "#{value1}#{value2}"
      #   end
      #   def body
      #     composite {
      #       fill_layout :horizontal
      #       @label1 = label(swt_style) {
      #         background color1
      #       }
      #       @label2 = label(swt_style) {
      #         background color2
      #       }
      #     }
      #   end
      # end
      module Red
        class Composite
          include Glimmer::SWT::CustomWidget
          def body
            composite(swt_style) {
              background :red
            }
          end
        end
        class Label
          include Glimmer::SWT::CustomWidget
          def body
            label(swt_style) {
              background :red
            }
          end
        end
      end
      class Sandwich
        include Glimmer::SWT::CustomWidget
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
    end

    after do
      @target.display.dispose if @target.display
      self.class.send(:define_method, :display, @rspec_display_method)
      Object.send(:remove_const, :RedLabel) if Object.const_defined?(:RedLabel)
      Glimmer.send(:remove_const, :Red) if Glimmer.const_defined?(:Red)
      Glimmer.send(:remove_const, :Sandwich) if Glimmer.const_defined?(:Sandwich)
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
          @red_label = glimmer__red__label {
            text 'Red Label'
          }
        }
      }

      expect(@red_composite.widget.getParent).to eq(@target.widget)
      expect(@red_composite.widget.getBackground).to eq(GColor.color_for(:red))
      expect(@red_label.widget.getParent).to eq(@red_composite.widget)
      expect(@red_label.widget.getBackground).to eq(GColor.color_for(:red))
      expect(@red_label.widget.getText).to eq('Red Label')
    end
  end
end
