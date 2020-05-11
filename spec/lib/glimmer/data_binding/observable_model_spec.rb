require "spec_helper"

module GlimmerSpec
  describe Glimmer::DataBinding::ObservableModel do
    before(:all) do
      class Person
        attr_accessor :name
      end

      class SpecObserver
        include Glimmer::DataBinding::Observer
        attr_reader :observed_name
        def call(name)
          @observed_name = name
        end
      end
    end

    after(:all) do
      %w[
        Person
        SpecPerson
      ].each do |constant|
        Object.send(:remove_const, constant) if Object.const_defined?(constant)
      end
    end

    it 'observes model' do
      person = Person.new
      person.name = "Marty"
      expect(person.name).to eq("Marty")
      observer = SpecObserver.new
      observer.observe(person, :name)
      person.name = "Julia"
      expect(observer.observed_name).to eq("Julia")
      expect(person.name).to eq("Julia")
    end

    it 'implements inspect (to avoid printing all observers by default)' do
      person = Person.new
      person.name = "Marty"
      expect(person.name).to eq("Marty")
      observer = SpecObserver.new
      observer.observe(person, :name)
      expect(person.inspect).to_not include('SpecObserver')
      expect(person.inspect).to match(/#<GlimmerSpec::Person:0x.*>/)
    end
  end
end
