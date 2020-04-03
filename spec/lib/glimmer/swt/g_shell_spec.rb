require "spec_helper"

module Glimmer
  module SWT
    describe GShell do
      include Glimmer

      before do
      end

      after do
        @target.close if @target && !@target.widget.isDisposed
      end

      describe '#visible?' do
        it 'returns false before initially opened and true afterwards' do
          @target = GShell.new
          @target.widget.setAlpha(0) # keep invisible while running specs
          expect(@target.visible?).to eq(false)
          @target.async_exec do
            expect(@target.visible?).to eq(true)
            @target.close
            expect(@target.visible?).to eq(false)
          end
          @target.open
        end

        it 'returns false if hidden after initially opened (this time with alias method show)' do
          @target = GShell.new
          @target.widget.setAlpha(0) # keep invisible while running specs
          @target.async_exec do
            expect(@target.visible?).to eq(true)
            @target.hide
            expect(@target.visible?).to eq(false)
            @target.close
          end
          @target.show
        end

        it 'returns false when visibility is set to false in GShell' do
          @target = GShell.new
          @target.widget.setAlpha(0) # keep invisible while running specs
          @target.async_exec do
            expect(@target.visible?).to eq(true)
            @target.visible = false
            expect(@target.visible?).to eq(false)
            expect(@target.widget.isVisible).to eq(false)
            @target.close
          end
          @target.visible = true
        end
      end

      describe 'visibility observation' do
        it 'notifies when becoming visible' do
          @target = GShell.new
          @target.widget.setAlpha(0) # keep invisible while running specs
          @target.on_event_show {
            expect(@target.visible?).to eq(true)
            @target.close
          }
          expect(@target.visible?).to eq(false)
          @target.show
        end

        it 'notifies when becoming non-visible (observed with alternative syntax)' do
          @target = GShell.new
          @target.widget.setAlpha(0) # keep invisible while running specs
          @target.async_exec do
            expect(@target.visible?).to eq(true)
            @target.on_event_hide {
              expect(@target.visible?).to eq(false)
              @target.close
            }
            @target.hide
          end
          @target.show
        end
      end
    end
  end
end
