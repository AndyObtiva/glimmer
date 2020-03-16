require "spec_helper"

describe "Glimmer Tree Data Binding" do
  include Glimmer

  before do
    dsl :swt

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
  end

	after do
  	@target.display.dispose if @target && @target.display
    %w[
      Person
      Manager
      Company
    ].each do |constant|
      Object.send(:remove_const, constant) if Object.const_defined?(constant)
    end
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
    node1 = rootNode.getItems[0]
    node2 = rootNode.getItems[1]
    expect(node1.getText()).to eq("Bruce Ting")
    expect(node2.getText()).to eq("Julia Fang")

    manager.name = "Tim Lee Harkins"

    rootNode = @tree.widget.getItems[0]
    expect(rootNode.getText()).to eq("Tim Lee Harkins")

    person1.name = "Bruce A. Ting"
    node1 = @tree.widget.getItems.first.getItems.first
    expect(node1.getText()).to eq("Bruce A. Ting")

    person2.name = "Julia Katherine Fang"
    node2 = @tree.widget.getItems.first.getItems.last
    expect(node2.getText()).to eq("Julia Katherine Fang")

    person3 = Person.new
    person3.name = "Bob David Kennith"
    person3.age = 37
    person3.adult = true

    manager.people << person3
    manager.people = manager.people

    rootNode = @tree.widget.getItems.first
    expect(rootNode.getItems.size).to eq(3)
    node3 = rootNode.getItems.last
    expect(node3.getText()).to eq("Bob David Kennith")

    manager.people.delete_at(0)

    rootNode = @tree.widget.getItems.first
    expect(rootNode.getItems.size).to eq(2)
    node1 = rootNode.getItems.first
    node2 = rootNode.getItems.last
    expect(node1.getText()).to eq("Julia Katherine Fang")
    expect(node2.getText()).to eq("Bob David Kennith")

  end

end
