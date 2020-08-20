require 'spec_helper'

require 'tempfile'

module GlimmerSpec
  describe Glimmer::DSL::Expression do
    before :all do
      class SomeExpresion < Glimmer::DSL::Expression
      end
    end

    after :all do
      Object.send(:remove_const, :SomeExpresion) if Object.const_defined?(:SomeExpresion)
    end
  
    it 'returns error if can_interpret? is called' do
      expect { 
        SomeExpresion.new.can_interpret?(Object.new, 'keyword') 
      }.to raise_error("#can_interpret? must be implemented by an Expression subclass")
    end
  
    it 'returns error if interpret is called' do
      expect { 
        SomeExpresion.new.interpret(Object.new, 'keyword') 
      }.to raise_error("#interpret must be implemented by an Expression subclass")
    end
    
    describe '#textual?' do
      it 'returns true for string' do
        expect(SomeExpresion.new.textual?('string')).to eq(true)
      end
      
      it 'returns true for symbol' do
        expect(SomeExpresion.new.textual?(:symbol)).to eq(true)
      end
      
      it 'returns false for other types (integer)' do
        expect(SomeExpresion.new.textual?(3)).to eq(false)
      end
      
    end
  
  end
end
