require "spec_helper"

describe ObservableModel do
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
