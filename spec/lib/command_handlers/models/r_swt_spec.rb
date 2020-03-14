require "spec_helper"

describe RSwt do
  describe '.constant' do
    it 'returns SWT constant value for symbol' do
      expect(RSwt.constant(:border)).to eq(org.eclipse.swt.SWT::BORDER)
    end

    it 'returns SWT constant value for symbol representing an SWT constant that is not all caps' do
      expect(RSwt.constant(:selection)).to eq(org.eclipse.swt.SWT::Selection)
    end

    it 'returns SWT constant value for string' do
      expect(RSwt.constant('border')).to eq(org.eclipse.swt.SWT::BORDER)
    end

    it 'returns SWT constant value as is when passed in as a number' do
      swt_constant = org.eclipse.swt.SWT::BORDER
      expect(RSwt.constant(swt_constant)).to eq(swt_constant)
    end
  end

  describe '.[]' do
    context 'single argument' do
      it 'returns SWT constant value' do
        expect(RSwt[:border]).to eq(org.eclipse.swt.SWT::BORDER)
      end

      it 'returns SWT constant value 0 (SWT::NONE) for nil' do
        expect(RSwt[nil]).to eq(org.eclipse.swt.SWT::NONE)
      end
    end

    context 'multiple arguments' do
      it 'returns SWT constant value for homogonous values (symbols)' do
        expect(RSwt[:border, :v_scroll]).to eq(org.eclipse.swt.SWT::BORDER | org.eclipse.swt.SWT::V_SCROLL)
      end

      it 'returns SWT constant value for mixed values (symbol, string, and integer)' do
        expect(RSwt['border', :v_scroll, org.eclipse.swt.SWT::CENTER]).to eq(org.eclipse.swt.SWT::BORDER | org.eclipse.swt.SWT::V_SCROLL | org.eclipse.swt.SWT::CENTER)
      end
    end

    context 'empty arguments' do
      it 'returns SWT constant value 0 (SWT::NONE) for empty arguments' do
        expect(RSwt[]).to eq(org.eclipse.swt.SWT::NONE)
      end
    end
  end
end
