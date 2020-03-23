require "spec_helper"

module Glimmer
  module SWT
    describe ObservableModel do
      before do
        class Person
          attr_accessor :name
        end

        class SpecObserver
          include Observer
          attr_reader :observed_name
          def call(name)
            @observed_name = name
          end
        end
      end

      after do
        Object.send(:remove_const, :Person) if Object.const_defined?(:Person)
        Object.send(:remove_const, :SpecPerson) if Object.const_defined?(:SpecPerson)
      end

      it "observes model" do
        person = Person.new
        person.name = "Marty"
        expect(person.name).to eq("Marty")
        observer = SpecObserver.new
        observer.observe(person, :name)
        person.name = "Julia"
        expect(observer.observed_name).to eq("Julia")
        expect(person.name).to eq("Julia")
      end
    end
  end
end
