require "spec_helper"

module GlimmerSpec
  describe Glimmer::UI::CustomShell do
    include Glimmer

    before(:all) do
      class ::TimeShell
        include Glimmer::UI::CustomShell

        body {
          shell {
            alpha 0 # keep invisible while running specs
            label {
              text "It is always beer'o'clock!"
            }
          }
        }
      end

      class ::InvalidCustomShell
        include Glimmer::UI::CustomShell

        body {
          composite
        }
      end
    end

    after(:all) do
      Object.send(:remove_const, :TimeShell) if Object.const_defined?(:TimeShell)
      Object.send(:remove_const, :InvalidCustomShell) if Object.const_defined?(:InvalidCustomShell)
    end

    after do
      if @target && !@target.swt_widget.isDisposed
        @target.async_exec do
          @target.dispose
        end
        @target.open
      end
    end

    it 'opens and closes' do
      @target = time_shell
      @target.swt_widget.setAlpha(0) # keep invisible while running specs
      expect(@target.swt_widget.children.first.is_a?(Label)).to eq(true)
      expect(@target.swt_widget.children.first.getText).to eq("It is always beer'o'clock!")
      expect(@target.visible?).to eq(false)
      @target.async_exec do
        expect(@target.visible?).to eq(true)
      end
    end

    it 'rejects a non shell body root' do
      expect do
        invalid_custom_shell
      end.to raise_error(NameError)
    end

    it 'handles events' do
      @target = time_shell
      @target.on_event_hide do
        @time_shell_hidden = true
      end
      @target.async_exec do
        @target.hide
      end
      @target.async_exec do
        expect(@time_shell_hidden).to eq(true)
      end
    end
  end
end
