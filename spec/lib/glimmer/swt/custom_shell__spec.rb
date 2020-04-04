require "spec_helper"

module Glimmer
  module SWT
    describe CustomShell do
      include Glimmer

      before(:all) do
        class ::TimeShell
          include Glimmer::SWT::CustomShell

          def body
            shell {
              label {
                text "It is always beer'o'clock!"
              }
            }
          end
        end
      end

      after(:all) do
        Object.send(:remove_const, :TimeShell) if Object.const_defined?(:TimeShell)
      end

      before do
        @rspec_display_method = method(:display)
        self.class.send(:undef_method, :display)
        dsl :swt
      end

      after do
        @target.close if @target && !@target.widget.isDisposed
        self.class.send(:define_method, :display, @rspec_display_method)
      end

      it 'opens and closes' do
        @target = time_shell
        @target.widget.setAlpha(0) # keep invisible while running specs
        expect(@target.visible?).to eq(false)
        @target.async_exec do
          expect(@target.visible?).to eq(true)
          @target.close
          expect(@target.widget.isDisposed).to eq(true)
        end
        @target.open
      end

      it 'rejects a non shell body root' do
        expect do
          class ::TimeCompositeCustomShell
            include Glimmer::SWT::CustomShell

            def body
              composite {
                label {
                  text "It is always beer'o'clock!"
                }
              }
            end
          end
          @target = time_composite_custom_shell
        end.to raise_error(RuntimeError)
      end
    end
  end
end
