require "spec_helper"

module Glimmer
  module SWT
    describe GWidget do
      include Glimmer

      before do
        dsl :swt
      end

      after do
        @target.start_event_loop
      end

      it 'asyncronously executes' do
        @target = shell {
          @text = text {
            text "text1"
          }
        }

        @target.async_exec do
          @text.widget.setText("text2")
        end

        @target.async_exec do
          expect(@text.widget.getText).to eq("text2")
          @target.widget.close
        end
      end

      it "syncronously executes" do
        @target = shell {
          @text = text {
            text "text1"
          }
        }

        @target.async_exec do
          expect(@text.widget.getText).to eq("text2")
          @text.widget.setText("text3")
        end

        @target.sync_exec do
          @text.widget.setText("text2")
        end

        @target.async_exec do
          @target.widget.close
        end
      end
    end
  end
end
