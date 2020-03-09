require "spec_helper"

describe ObservableModel do
  class Person
    attr_accessor :name
  end

  class SpecObserver
    include Observer
    attr_reader :observed_name
    def update(name)
      @observed_name = name
    end
  end

  it "observes model" do
    person = Person.new
    person.name = "Marty"
    expect(person.name).to eq("Marty")
    person.extend(ObservableModel)
    observer = SpecObserver.new
    person.add_observer(:name, observer)
    person.name = "Julia"
    expect(observer.observed_name).to eq("Julia")
    expect(person.name).to eq("Julia")
  end
end
