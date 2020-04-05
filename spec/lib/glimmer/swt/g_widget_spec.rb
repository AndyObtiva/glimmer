require "spec_helper"

module Glimmer
  module SWT
    describe GWidget do
      include Glimmer

      it 'adds listener' do
        @target = shell {
          composite {
            @text = text {
              text "Howdy"
            }
            @text.on_verify_text do |verify_event|
              verify_event.doit = false if verify_event.text == "Hello"
            end
          }
        }

        @text.widget.setText("Hi")
        expect(@text.widget.getText).to eq("Hi")

        @text.widget.setText("Hello")
        expect(@text.widget.getText).to eq("Hi")
      end

      it 'adds content' do
        @target = shell {
          minimum_size 50, 20
        }

        @target.content {
          minimum_size 300, 200
          composite {
            @text = text {
              text "Howdy"
            }
          }
        }

        expect(@target.widget.getMinimumSize.x).to eq(300)
        expect(@target.widget.getMinimumSize.y).to eq(200)
        expect(@text.widget.getText).to eq("Howdy")
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
            @text = text {
              text "text1"
            }
          }

          @target.async_exec do
            expect(@text.widget.getText).to eq("text2")
          end

          # This takes prioerity over async_exec
          @target.sync_exec do
            @text.widget.setText("text2")
          end
        end
      end
    end
  end
end
