require 'spec_helper'
require 'glimmer/data_binding/model_binding'

describe Glimmer::DataBinding::ModelBinding do
  context 'converters' do
    before(:all) do
      class Person
        attr_accessor :name, :age, :spouse
      end
    end
  
    after(:all) do
      %w[
        Person
      ].each do |constant|
        Object.send(:remove_const, constant) if Object.const_defined?(constant)
      end
    end
    
    let(:person) { Person.new }
    let(:spouse) { Person.new }
  
    it "converts value on write to model via value method symbol" do
      @model_binding = described_class.new(person, :age, on_write: :to_i)
  
      @model_binding.call('30')
      expect(person.age).to eq(30)
    end
  
    it "converts value on write to model with lambda" do
      @model_binding = described_class.new(person, :age, on_write: lambda {|a| a.to_i})
  
      @model_binding.call('30')
      expect(person.age).to eq(30)
    end
  
    it "raises a Glimmer:Error if on_write converter is an invalid value method symbol" do
      @model_binding = described_class.new(person, :age, on_write: :to_garbage)
  
      expect {
        @model_binding.call('30')
      }.to raise_error(Glimmer::Error)
    end
  
    it "raises a Glimmer:Error if on_write converter is an invalid object" do
      @model_binding = described_class.new(person, :age, on_write: 33)
  
      expect {
        @model_binding.call('30')
      }.to raise_error(Glimmer::Error)
    end
  
    it "converts value on write to widget using built-in default widget property data-binding converter" do
      person.age = 15
  
      @model_binding = described_class.new(person, :age, on_read: :to_s)
  
      expect(@model_binding.evaluate_property).to eq("15")
  
      person.age = 27
      expect(@model_binding.evaluate_property).to eq("27")
    end
  
    it "converts value on read from model via value method symbol" do
      person.name = 'Sean McFaun'
  
      @model_binding = described_class.new(person, :name, on_read: :upcase)
  
      expect(@model_binding.evaluate_property).to eq('SEAN MCFAUN')
  
      person.name = 'Johnny Francone'
      expect(@model_binding.evaluate_property).to eq('JOHNNY FRANCONE')
    end
  
    it "converts value on read from model with lambda" do
      person.name = 'Sean McFaun'
  
      @model_binding = described_class.new(person, :name, on_read: lambda {|n| n.split(' ').first})
  
      expect(@model_binding.evaluate_property).to eq('Sean')
  
      person.name = 'Johnny Francone'
      expect(@model_binding.evaluate_property).to eq('Johnny')
    end
  
    it "converts nil value on read from model" do
      person.name = 'John'
      spouse.name = 'Mary'
      person.spouse = spouse
  
      @model_binding = described_class.new(person, :name, on_read: lambda {|n| n.nil? ? 'ANONYMOUS' : n.upcase})
      @model_binding2 = described_class.new(person, 'spouse.name', on_read: lambda {|n| n.nil? ? 'ANONYMOUS' : n.upcase})
  
      expect(@model_binding.evaluate_property).to eq('JOHN')
      expect(@model_binding2.evaluate_property).to eq('MARY')
  
      person.name = 'Johnny'
      expect(@model_binding.evaluate_property).to eq('JOHNNY')
      spouse.name = 'Marianne'
      expect(@model_binding2.evaluate_property).to eq('MARIANNE')
  
      person.name = nil
      expect(@model_binding.evaluate_property).to eq('ANONYMOUS')
      person.spouse = nil
      expect(@model_binding2.evaluate_property).to eq('ANONYMOUS')
    end
  
    it "converts value on read and write from model via value method symbols" do
      person.name = 'Sean McFaun'
  
      @model_binding = described_class.new(person, :name, on_read: :upcase, on_write: :downcase)
  
      expect(@model_binding.evaluate_property).to eq('SEAN MCFAUN')
  
      @model_binding.call('Provan McCullough')
      expect(person.name).to eq('provan mccullough')
      expect(@model_binding.evaluate_property).to eq('PROVAN MCCULLOUGH')
    end
  
    it "converts value on read and write from model via lambdas" do
      person.name = 'Sean McFaun'
  
      @model_binding = described_class.new(person, :name, on_read: lambda {|n| n.upcase}, on_write: lambda {|n| n.downcase})
  
      expect(@model_binding.evaluate_property).to eq('SEAN MCFAUN')
  
      @model_binding.call('Provan McCullough')
      expect(person.name).to eq('provan mccullough')
      expect(@model_binding.evaluate_property).to eq('PROVAN MCCULLOUGH')
    end
  end
end
