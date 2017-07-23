require "spec_helper"

describe ObservableModel do
  class Person
    attr_accessor :name
  end

  it "observes model" do
    person = Person.new
    person.name = "Marty"
    expect(person.name).to eq("Marty")
    person.extend ObservableModel
    person.add_observer(:name, self)
    person.name = "Julia"
    expect(@observed_name).to eq("Julia")
    expect(person.name).to eq("Julia")
  end

  def update(name)
    @observed_name = name
  end
end
