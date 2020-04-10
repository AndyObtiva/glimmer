require "spec_helper"

module GlimmerSpec
  describe "Glimmer swt" do
    include Glimmer

    it 'returns SWT constant value for a single symbol' do
      expect(swt(:center)).to eq(SWT::CENTER)
    end

    it 'returns SWT constant value for a single string' do
      expect(swt('center')).to eq(SWT::CENTER)
    end

    it 'returns SWT constant value for a multiple symbols' do
      expect(swt(:center, :border)).to eq(SWT::CENTER | SWT::BORDER)
    end

    it 'returns SWT constant value for a multiple strings' do
      expect(swt('center', 'border')).to eq(SWT::CENTER | SWT::BORDER)
    end

    it 'errors out when passed no values' do
      expect{swt}.to raise_error(Glimmer::Error)
    end
  end
end
