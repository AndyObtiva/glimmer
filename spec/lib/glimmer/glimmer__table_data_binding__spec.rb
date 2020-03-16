require "spec_helper"

module Glimmer
  describe "Glimmer Table Data Binding" do
    include Glimmer

    before do
      dsl :swt

      class PersonGroup
        attr_accessor :people

        def initialize
          @people = []
        end
      end

      class Person
        attr_accessor :name, :age, :adult
      end
    end

    after do
      @target.display.dispose if @target.display
      Object.send(:remove_const, :PersonGroup) if Object.const_defined?(:PersonGroup)
      Object.send(:remove_const, :Person) if Object.const_defined?(:Person)
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

      group = PersonGroup.new
      group.people << person1
      group.people << person2

      @target = shell {
        @table = table {
          table_column {
            text "Name"
            width 120
          }
          table_column {
            text "Age"
            width 120
          }
          table_column {
            text "Adult"
            width 120
          }
          items bind(group, :people), column_properties(:name, :age, :adult)
        }
      }

      expect(@table.widget.getColumnCount).to eq(3)
      expect(@table.widget.getItems.size).to eq(2)

      expect(@table.widget.getItems[0].getText(0)).to eq("Bruce Ting")
      expect(@table.widget.getItems[0].getText(1)).to eq("45")
      expect(@table.widget.getItems[0].getText(2)).to eq("true")

      expect(@table.widget.getItems[1].getText(0)).to eq("Julia Fang")
      expect(@table.widget.getItems[1].getText(1)).to eq("17")
      expect(@table.widget.getItems[1].getText(2)).to eq("false")

      person3 = Person.new
      person3.name = "Andrea Shingle"
      person3.age = 23
      person3.adult = true

      group.people << person3

      expect(@table.widget.getItems.size).to eq(3)
      expect(@table.widget.getItems[2].getText(0)).to eq("Andrea Shingle")
      expect(@table.widget.getItems[2].getText(1)).to eq("23")
      expect(@table.widget.getItems[2].getText(2)).to eq("true")

      group.people.delete person2

      expect(@table.widget.getItems.size).to eq(2)
      expect(@table.widget.getItems[1].getText(0)).to eq("Andrea Shingle")
      expect(@table.widget.getItems[1].getText(1)).to eq("23")
      expect(@table.widget.getItems[1].getText(2)).to eq("true")

      group.people.delete_at(0)

      expect(@table.widget.getItems.size).to eq(1)
      expect(@table.widget.getItems[0].getText(0)).to eq("Andrea Shingle")
      expect(@table.widget.getItems[0].getText(1)).to eq("23")
      expect(@table.widget.getItems[0].getText(2)).to eq("true")

      group.people.clear

      expect(0).to eq(@table.widget.getItems.size)

      group.people = [person2, person1]

      expect(2).to eq(@table.widget.getItems.size)

      expect(@table.widget.getItems[0].getText(0)).to eq("Julia Fang")
      expect(@table.widget.getItems[0].getText(1)).to eq("17")
      expect(@table.widget.getItems[0].getText(2)).to eq("false")

      expect(@table.widget.getItems[1].getText(0)).to eq("Bruce Ting")
      expect(@table.widget.getItems[1].getText(1)).to eq("45")
      expect(@table.widget.getItems[1].getText(2)).to eq("true")

      person1.name = "Bruce Flee"

      expect(@table.widget.getItems[1].getText(0)).to eq("Bruce Flee")
    end

  end
end
