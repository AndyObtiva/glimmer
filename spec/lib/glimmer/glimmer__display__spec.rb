require "spec_helper"

module Glimmer
  describe "Glimmer Display" do
    include Glimmer

    before do
      @rspec_display_method = method(:display)
      self.class.send(:undef_method, :display)
      dsl :swt
    end

    after do
      self.class.send(:define_method, :display, @rspec_display_method)
    end

    context 'standard operation' do
      after do
        @target.dispose if @target
        @target2.dispose if @target2
        self.class.send(:define_method, :display, @rspec_display_method)
      end

      it "instantiates display" do
        @target = display

        expect(@target).to be_a(GDisplay)
        expect(@target.display).to be_a(Display)
        expect(@target.display.isDisposed).to be_falsey

        @target2 = display
        expect(@target2.display).to eq(@target.display)

        @target2.dispose
        @target2 = display
        expect(@target2.display).to_not eq(@target.display)
      end
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
          @text = text {
            text "text1"
          }
        }

        @target.async_exec do
          @text.widget.setText("text2")
        end

        expect(@text.widget.getText).to_not eq("text2")

        @target.async_exec do
          expect(@text.widget.getText).to eq("text2")
        end
      end

      it "syncronously executes UI code" do
        @target = shell {
          @text = text {
            text "text1"
          }
        }

        @target.async_exec do
          expect(@text.widget.getText).to eq("text2")
        end

        @target.sync_exec do
          @text.widget.setText("text2")
        end
      end
    end

  end
end
