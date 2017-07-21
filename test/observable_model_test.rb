require_relative "helper"

require_relative "../lib/command_handlers/models/observable_model"

require "test/unit"
class ObservableModelTest < Test::Unit::TestCase
  class Person 
    attr_accessor :name
  end

  def test_observe_model
    person = Person.new
    person.name = "Marty"
    assert_equal "Marty", person.name
    person.extend ObservableModel
    person.add_observer(:name, self)
    person.name = "Julia"
    assert_equal "Julia", @observed_name
    assert_equal "Julia", person.name
  end
  
  def update(name)
    @observed_name = name
  end
end