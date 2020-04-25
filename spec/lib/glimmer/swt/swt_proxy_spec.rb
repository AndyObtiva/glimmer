require "spec_helper"

java_import 'org.eclipse.swt.SWT'

module GlimmerSpec
  describe Glimmer::SWT::SWTProxy do
    describe '.constant' do
      it 'returns SWT constant value for symbol' do
        expect(Glimmer::SWT::SWTProxy.constant(:border)).to eq(::SWT::BORDER)
      end

      it 'returns SWT constant value for symbol representing an SWT constant that is not all caps' do
        expect(Glimmer::SWT::SWTProxy.constant(:selection)).to eq(::SWT::Selection)
      end

      it 'returns SWT constant value for symbol representing an SWT constant that is not all caps when not specified in lower case' do
        expect(Glimmer::SWT::SWTProxy.constant(:Resize)).to eq(::SWT::Resize)
      end

      it 'returns SWT constant value for symbol representing an SWT constant that is all caps when specified in lower case' do
        expect(Glimmer::SWT::SWTProxy.constant(:resize)).to eq(::SWT::RESIZE)
      end

      it 'returns SWT constant value for symbol representing an extra SWT constant added in Glimmer for convenience' do
        expect(Glimmer::SWT::SWTProxy.constant(:no_resize)).to eq(::SWT::SHELL_TRIM & ~::SWT::RESIZE & ~::SWT::MAX)
      end

      it 'returns SWT constant value for a negative symbol (postfixed by !)' do
        expect(Glimmer::SWT::SWTProxy.constant(:max!)).to eq(~::SWT::MAX)
      end

      it 'returns SWT constant value for a negative symbol that is not all caps in SWT' do
        expect(Glimmer::SWT::SWTProxy.constant(:activate!)).to eq(~::SWT::Activate)
      end

      it 'returns SWT constant value for a negative symbol representing an extra SWT constant added in Glimmer for convenience' do
        expect(Glimmer::SWT::SWTProxy.constant(:no_resize!)).to eq(~(::SWT::SHELL_TRIM & ~::SWT::RESIZE & ~::SWT::MAX))
      end

      it 'returns SWT constant value for string' do
        expect(Glimmer::SWT::SWTProxy.constant('border')).to eq(::SWT::BORDER)
      end

      it 'returns SWT constant value as is when passed in as a number' do
        swt_constant = ::SWT::BORDER
        expect(Glimmer::SWT::SWTProxy.constant(swt_constant)).to eq(swt_constant)
      end
    end

    describe '.[]' do
      context 'single argument' do
        it 'returns SWT constant value' do
          expect(Glimmer::SWT::SWTProxy[:border]).to eq(::SWT::BORDER)
        end

        it 'returns SWT constant value 0 (::SWT::NONE) for nil' do
          expect(Glimmer::SWT::SWTProxy[nil]).to eq(::SWT::NONE)
        end
      end

      context 'multiple arguments' do
        it 'returns SWT constant value for homogonous values (symbols)' do
          expect(Glimmer::SWT::SWTProxy[:border, :v_scroll]).to eq(::SWT::BORDER | ::SWT::V_SCROLL)
        end

        it 'returns SWT constant value for mixed values (symbol, string, and integer)' do
          expect(Glimmer::SWT::SWTProxy['border', :v_scroll, ::SWT::CENTER]).to eq(::SWT::BORDER | ::SWT::V_SCROLL | ::SWT::CENTER)
        end

        it 'returns SWT constant value for negative and positive symbols' do
          expect(Glimmer::SWT::SWTProxy[:shell_trim, :resize, :max!, :min!]).to eq((::SWT::SHELL_TRIM | ::SWT::SHELL_TRIM) & ~::SWT::MAX & ~::SWT::MIN)
        end
      end

      context 'empty arguments' do
        it 'returns SWT constant value 0 (::SWT::NONE) for empty arguments' do
          expect(Glimmer::SWT::SWTProxy[]).to eq(::SWT::NONE)
        end
      end

      context 'bad arguments' do
        it 'displays a friendly error message' do
          expect {Glimmer::SWT::SWTProxy[:bold, :beautiful]}.to raise_error("beautiful is an invalid SWT style! Please choose a style from org.eclipse.swt.SWT class constants.")
        end
      end
    end
  end
end
