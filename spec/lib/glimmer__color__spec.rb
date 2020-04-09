require "spec_helper"

module GlimmerSpec
  describe "Glimmer Color" do
    include Glimmer

    before do
      @rspec_display_method = method(:display)
      self.class.send(:undef_method, :display)
    end

    after do
      @target.dispose if @target
      self.class.send(:define_method, :display, @rspec_display_method)
    end

    it "tests label with RGBAlpha background/foreground color" do
      @foreground = rgba(4, 40, 244, 50) # get singleton display
      @foreground_color = @foreground.color
      @target = shell {
        @label = label {
          background rgba(4, 40, 244, 50) # get parent display
          foreground @foreground_color # set as SWT Color object
        }
      }

      color = @label.widget.getBackground
      expect(color.getRed).to eq(4)
      expect(color.getGreen).to eq(40)
      expect(color.getBlue).to eq(244)
      expect(color.getAlpha).to eq(50)

      expect(@foreground_color.getRed).to eq(4)
      expect(@foreground_color.getGreen).to eq(40)
      expect(@foreground_color.getBlue).to eq(244)
      expect(@foreground_color.getAlpha).to eq(50)
      expect(@foreground_color.getDevice).to eq(Glimmer::SWT::GDisplay.instance.swt_display)

      expect(@foreground_color.getDevice).to eq(Glimmer::SWT::DisplayProxy.instance.swt_display)
    end

    it "tests label with RGB (no alpha) background/foreground color" do
      @foreground = rgb(4, 40, 244) # get singleton display
      @foreground_color = @foreground.color
      @target = shell {
        @label = label {
          background rgb(4, 40, 244) # get parent display
          foreground @foreground_color # set as SWT Color object
        }
      }

      color = @label.widget.getBackground
      expect(color.getRed).to eq(4)
      expect(color.getGreen).to eq(40)
      expect(color.getBlue).to eq(244)

      expect(@foreground_color.getRed).to eq(4)
      expect(@foreground_color.getGreen).to eq(40)
      expect(@foreground_color.getBlue).to eq(244)
      expect(@foreground_color.getDevice).to eq(Glimmer::SWT::GDisplay.instance.swt_display)

      expect(@foreground_color.getDevice).to eq(Glimmer::SWT::DisplayProxy.instance.swt_display)
    end

    # Standard colors: not an exhaustive list. Sample taken from here: https://help.eclipse.org/2019-12/topic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/SWT.html
    [
      :color_black,
      'color_magenta',
      :black,
      'magenta',
    ].each do |standard_color|
      it "tests label with standard #{standard_color} background color passed as a Ruby symbol" do
        @target = shell {
          @label = label {
            background standard_color
            foreground standard_color
          }
        }

        background = @label.widget.getBackground
        foreground = @label.widget.getForeground
        swt_color_constant = Glimmer::SWT::GSWT['color_' + standard_color.to_s.sub(/^color_/, '')]
        expected_color = Glimmer::SWT::DisplayProxy.instance.swt_display.getSystemColor(swt_color_constant)
        expect(background).to eq(expected_color)
        expect(foreground).to eq(expected_color)
      end
    end

    it "tests label with RGBA background color utilizing existing display" do
      @display = display
      @background = rgba(@display.swt_display, 4, 40, 244, 100)
      @target = shell {
        @label = label {
          background @background
        }
      }

      color = @label.widget.getBackground
      expect(color.getRed).to eq(4)
      expect(color.getGreen).to eq(40)
      expect(color.getBlue).to eq(244)
      expect(color.getAlpha).to eq(100)
    end

    it "tests label with RGB background color utilizing existing display" do
      @display = display
      @background = rgb(@display.swt_display, 4, 40, 244)
      @target = shell {
        @label = label {
          background @background
        }
      }

      color = @label.widget.getBackground
      expect(color.getRed).to eq(4)
      expect(color.getGreen).to eq(40)
      expect(color.getBlue).to eq(244)
    end


    it "tests label with RGBA background color without a display nor a parent" do
      @background = rgba(4, 40, 244, 100)
      @target = shell {
        @label = label {
          background @background
        }
      }

      color = @label.widget.getBackground
      expect(color.getRed).to eq(4)
      expect(color.getGreen).to eq(40)
      expect(color.getBlue).to eq(244)
      expect(color.getAlpha).to eq(100)
    end

    it "tests label with RGB background color without a display nor a parent" do
      @background = rgba(4, 40, 244)
      @target = shell {
        @label = label {
          background @background
        }
      }

      color = @label.widget.getBackground
      expect(color.getRed).to eq(4)
      expect(color.getGreen).to eq(40)
      expect(color.getBlue).to eq(244)
    end
  end
end
