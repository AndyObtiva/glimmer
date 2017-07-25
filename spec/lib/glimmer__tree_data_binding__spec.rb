require "spec_helper"

describe "Glimmer Tree Data Binding" do
  include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'

  before do
    dsl :swt
  end

	after do
  	@target.display.dispose if @target.display
	end

  class Person
    attr_accessor :name, :age, :adult, :people
  end

  class Manager < Person
    def initialize
      @people = []
    end

    attr_accessor :people
  end

  class Company
    def initialize
      @owner = []
    end

    attr_accessor :owner
  end

  it "data binds text widget to a string property" do
    person1 = Person.new
    person1.name = "Bruce Ting"
    person1.age = 45
    person1.adult = true

    person2 = Person.new
    person2.name = "Julia Fang"
    person2.age = 17
    person2.adult = false

    manager = Manager.new
    manager.name = "Tim Harkins"
    manager.age = 79
    manager.adult = true
    manager.people << person1
    manager.people << person2

    company = Company.new
    company.owner = manager

    @target = shell {
      @tree = tree(:virtual, :border) {
        items bind(company, :owner), tree_properties(children: :people, text: :name)
      }
    }

    expect(@tree.widget.getItems.size).to eq(1)

    rootNode = @tree.widget.getItems[0]
    expect(rootNode.getText()).to eq("Tim Harkins")

    expect(rootNode.getItems.size).to eq(2)
    expect(rootNode.getItems[0].getText()).to eq("Bruce Ting")
    expect(rootNode.getItems[1].getText()).to eq("Julia Fang")
  end

end
