require "spec_helper"

java_import 'org.eclipse.swt.SWT'

module Glimmer
  module SWT
    describe GSWT do
      describe '.constant' do
        it 'returns SWT constant value for symbol' do
          expect(Glimmer::SWT::GSWT.constant(:border)).to eq(::SWT::BORDER)
        end

        it 'returns SWT constant value for symbol representing an SWT constant that is not all caps' do
          expect(Glimmer::SWT::GSWT.constant(:selection)).to eq(::SWT::Selection)
        end

        it 'returns SWT constant value for symbol representing an SWT constant that is not all caps when not specified in lower case' do
          expect(Glimmer::SWT::GSWT.constant(:Resize)).to eq(::SWT::Resize)
        end

        it 'returns SWT constant value for symbol representing an SWT constant that is all caps when specified in lower case' do
          expect(Glimmer::SWT::GSWT.constant(:resize)).to eq(::SWT::RESIZE)
        end

        it 'returns SWT constant value for symbol representing an extra SWT constant added in Glimmer for convenience' do
          expect(Glimmer::SWT::GSWT.constant(:no_resize)).to eq(Glimmer::SWT::GSWT[:shell_trim] & (~GSWT[:resize]) & (~GSWT[:max]))
        end

        it 'returns SWT constant value for string' do
          expect(Glimmer::SWT::GSWT.constant('border')).to eq(::SWT::BORDER)
        end

        it 'returns SWT constant value as is when passed in as a number' do
          swt_constant = ::SWT::BORDER
          expect(Glimmer::SWT::GSWT.constant(swt_constant)).to eq(swt_constant)
        end
      end

      describe '.[]' do
        context 'single argument' do
          it 'returns SWT constant value' do
            expect(Glimmer::SWT::GSWT[:border]).to eq(::SWT::BORDER)
          end

          it 'returns SWT constant value 0 (::SWT::NONE) for nil' do
            expect(Glimmer::SWT::GSWT[nil]).to eq(::SWT::NONE)
          end
        end

        context 'multiple arguments' do
          it 'returns SWT constant value for homogonous values (symbols)' do
            expect(Glimmer::SWT::GSWT[:border, :v_scroll]).to eq(::SWT::BORDER | ::SWT::V_SCROLL)
          end

          it 'returns SWT constant value for mixed values (symbol, string, and integer)' do
            expect(Glimmer::SWT::GSWT['border', :v_scroll, ::SWT::CENTER]).to eq(::SWT::BORDER | ::SWT::V_SCROLL | ::SWT::CENTER)
          end
        end

        context 'empty arguments' do
          it 'returns SWT constant value 0 (::SWT::NONE) for empty arguments' do
            expect(Glimmer::SWT::GSWT[]).to eq(::SWT::NONE)
          end
        end

        context 'bad arguments' do
          it 'displays a friendly error message' do
            expect {GSWT[:bold, :beautiful]}.to raise_error("beautiful is an invalid SWT style! Please choose a style from org.eclipse.swt.SWT class constants.")
          end
        end
      end
    end
  end
end
