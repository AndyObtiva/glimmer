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

        class ::InvalidCustomShell
          include Glimmer::SWT::CustomShell

          def body
            composite {
              label {
                text "It is always beer'o'clock!"
              }
            }
          end
        end
      end

      after(:all) do
        Object.send(:remove_const, :TimeShell) if Object.const_defined?(:TimeShell)
        Object.send(:remove_const, :InvalidCustomShell) if Object.const_defined?(:InvalidCustomShell)
      end

      before do
        @rspec_display_method = method(:display)
        self.class.send(:undef_method, :display)
      end

      after do
        if @target
          @target.async_exec do
            @target.dispose
          end
          @target.open
        end
        self.class.send(:define_method, :display, @rspec_display_method)
      end

      it 'opens and closes' do
        # require 'jruby/profiler'

        # profile_data = JRuby::Profiler.profile do
          @target = time_shell
          @target.widget.setAlpha(0) # keep invisible while running specs
          expect(@target.visible?).to eq(false)
          @target.async_exec do
            expect(@target.visible?).to eq(true)
          end
        # end
        # profile_data
        # profile_printer = JRuby::Profiler::HtmlProfilePrinter.new(profile_data)
        # ps = java.io.PrintStream.new(STDOUT.to_outputstream)
        # profile_printer.printHeader(ps)
        # profile_printer.printProfile(ps)
        # profile_printer.printFooter(ps)
      end

      it 'rejects a non shell body root' do
        expect do
          time_composite_custom_shell
        end.to raise_error(RuntimeError)
      end
    end
  end
end
