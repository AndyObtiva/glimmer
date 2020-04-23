require "spec_helper"

module GlimmerSpec
  context 'UI code execution' do
    include Glimmer

    after do
      if @target
        @target.async_exec do
          @target.dispose
        end
        @target.start_event_loop
      end
    end

    it 'asyncronously executes UI code' do
      @target = shell {
        @text = text {
          text "text1"
        }
      }

      async_exec do
        @text.swt_widget.setText("text2")
      end

      expect(@text.swt_widget.getText).to_not eq("text2")

      async_exec do
        expect(@text.swt_widget.getText).to eq("text2")
      end
    end

    it "syncronously executes UI code" do
      @target = shell {
        @text = text {
          text "text1"
        }
      }

      async_exec do
        expect(@text.swt_widget.getText).to eq("text2")
      end

      # This takes prioerity over async_exec
      sync_exec do
        @text.swt_widget.setText("text2")
      end
    end
  end
end
