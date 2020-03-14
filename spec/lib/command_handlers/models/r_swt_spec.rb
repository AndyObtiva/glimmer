require "spec_helper"

java_import 'org.eclipse.swt.SWT'

describe RSwt do
  describe '.constant' do
    it 'returns SWT constant value for symbol' do
      expect(RSwt.constant(:border)).to eq(SWT::BORDER)
    end

    it 'returns SWT constant value for symbol representing an SWT constant that is not all caps' do
      expect(RSwt.constant(:selection)).to eq(SWT::Selection)
    end

    it 'returns SWT constant value for string' do
      expect(RSwt.constant('border')).to eq(SWT::BORDER)
    end

    it 'returns SWT constant value as is when passed in as a number' do
      swt_constant = SWT::BORDER
      expect(RSwt.constant(swt_constant)).to eq(swt_constant)
    end
  end

  describe '.[]' do
    context 'single argument' do
      it 'returns SWT constant value' do
        expect(RSwt[:border]).to eq(SWT::BORDER)
      end

      it 'returns SWT constant value 0 (SWT::NONE) for nil' do
        expect(RSwt[nil]).to eq(SWT::NONE)
      end
    end

    context 'multiple arguments' do
      it 'returns SWT constant value for homogonous values (symbols)' do
        expect(RSwt[:border, :v_scroll]).to eq(SWT::BORDER | SWT::V_SCROLL)
      end

      it 'returns SWT constant value for mixed values (symbol, string, and integer)' do
        expect(RSwt['border', :v_scroll, SWT::CENTER]).to eq(SWT::BORDER | SWT::V_SCROLL | SWT::CENTER)
      end
    end

    context 'empty arguments' do
      it 'returns SWT constant value 0 (SWT::NONE) for empty arguments' do
        expect(RSwt[]).to eq(SWT::NONE)
      end
    end
  end
end
