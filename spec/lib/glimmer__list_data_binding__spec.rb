require "spec_helper"

describe "Glimmer List Data Binding" do
  include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'

  SWT = org.eclipse.swt.SWT unless Object.const_defined?(:SWT)

  before do
    dsl :swt
  end

	after do
  	@target.display.dispose if @target.display
	end

  class Person
    attr_accessor :country, :country_options
    attr_accessor :provinces, :provinces_options

    def initialize
      self.country_options=[
        "",
        "Canada",
        "US",
        "Mexico"
      ]
      self.provinces_options=[
        "",
        "Quebec",
        "Ontario",
        "Manitoba",
        "Saskatchewan",
        "Alberta",
        "British Columbia",
        "Nova Skotia",
        "Newfoundland"
      ]
    end
  end

  it "tests single selection property" do
    person = Person.new

    @target = shell {
      @list = list {
        selection bind(person, :country)
      }
    }

    expect(@list.widget.item_count).to eq(4)
    expect(@list.widget.selection_index).to eq(-1)
    expect(@list.widget.selection.to_a).to eq([])

    @list.widget.select(1)
    @list.widget.notifyListeners(SWT::Selection, nil)
    expect(person.country).to eq("Canada")

    person.country_options << "France"

    expect(@list.widget.item_count).to eq(5)

    person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]

    expect(@list.widget.item_count).to eq(6)

    person.country_options << "Italy"
    person.country_options << "Germany"
    person.country_options << "Australia"

    expect(@list.widget.item_count).to eq(9)

    person.country = "Canada"

    expect(@list.widget.selection_index).to eq(1)
    expect(@list.widget.selection.to_a).to eq(["Canada"])

    person.country = "Russia"

    expect(@list.widget.selection_index).to eq(4)
    expect(@list.widget.selection.to_a).to eq(["Russia"])

    person.country = ""

    expect(@list.widget.selection_index).to eq(0)
    expect(@list.widget.selection.to_a).to eq([""])

    person.country = "Japan"

    expect(@list.widget.selection_index).to eq(0)
    expect(@list.widget.selection.to_a).to eq([""])

    @list.widget.select(2)
    @list.widget.notifyListeners(SWT::Selection, nil)
    expect(person.country).to eq("US")
  end

  it "tests single selection property with model preinitialized" do
    person = Person.new
    person.country = "Canada"

    @target = shell {
      @list = list {
        selection bind(person, :country)
      }
    }

    expect(@list.widget.item_count).to eq(4)
    expect(@list.widget.selection_index).to eq(1)
    expect(@list.widget.selection.to_a).to eq(["Canada"])

    @list.widget.select(2)
    @list.widget.notifyListeners(SWT::Selection, nil)
    expect(person.country).to eq("US")

    person.country_options << "France"

    expect(@list.widget.item_count).to eq(5)

    person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]

    expect(@list.widget.item_count).to eq(6)

    person.country_options << "Italy"
    person.country_options << "Germany"
    person.country_options << "Australia"

    expect(@list.widget.item_count).to eq(9)

    person.country = "Canada"

    expect(@list.widget.selection_index).to eq(1)
    expect(@list.widget.selection.to_a).to eq(["Canada"])

    person.country = "Russia"

    expect(@list.widget.selection_index).to eq(4)
    expect(@list.widget.selection.to_a).to eq(["Russia"])

    person.country = ""

    expect(@list.widget.selection_index).to eq(0)
    expect(@list.widget.selection.to_a).to eq([""])

    person.country = "Japan"

    expect(@list.widget.selection_index).to eq(0)
    expect(@list.widget.selection.to_a).to eq([""])
  end

  it "tests multi selection property" do
    person = Person.new

    @target = shell {
      @list = list(:multi) {
        selection bind(person, :provinces)
      }
    }

    expect(@list.widget.selection_count.to_i).to eq(0)
    expect(@list.widget.selection.to_a).to eq([])

    @list.widget.select(1)
    @list.widget.notifyListeners(SWT::Selection, nil)
    expect(person.provinces).to eq(["Quebec"])

    @list.widget.select(2)
    @list.widget.notifyListeners(SWT::Selection, nil)
    expect(person.provinces).to eq(["Quebec", "Ontario"])

    person.provinces=["Ontario", "Manitoba", "Alberta"]

    expect(@list.widget.selection_count.to_i).to eq(3)
    expect(@list.widget.selection_indices.to_a).to eq([2, 3, 5])
    expect(@list.widget.selection.to_a).to eq(["Ontario", "Manitoba", "Alberta"])

    person.provinces << "Quebec"
    person.provinces << "Saskatchewan"
    person.provinces << "British Columbia"

    expect(@list.widget.selection_count.to_i).to eq(6)
    expect(@list.widget.selection_indices.to_a).to eq([1, 2, 3, 4, 5, 6])
    expect(@list.widget.selection.to_a).to eq(["Quebec", "Ontario", "Manitoba", "Saskatchewan", "Alberta", "British Columbia"])
   end

  it "tests multi selection property with model preinitialized" do
    person = Person.new
    person.provinces = []

    @target = shell {
      @list = list(:multi) {
        selection bind(person, :provinces)
      }
    }

    expect(@list.widget.selection_count.to_i).to eq(0)
    expect(@list.widget.selection.to_a).to eq([])

    @list.widget.select(1)
    @list.widget.notifyListeners(SWT::Selection, nil)
    expect(person.provinces).to eq(["Quebec"])

    @list.widget.select(2)
    @list.widget.notifyListeners(SWT::Selection, nil)
    expect(person.provinces).to eq(["Quebec", "Ontario"])

    person.provinces=["Ontario", "Manitoba", "Alberta"]

    expect(@list.widget.selection_count.to_i).to eq(3)
    expect(@list.widget.selection_indices.to_a).to eq([2, 3, 5])
    expect(@list.widget.selection.to_a).to eq(["Ontario", "Manitoba", "Alberta"])

    person.provinces << "Quebec"
    person.provinces << "Saskatchewan"
    person.provinces << "British Columbia"

    expect(@list.widget.selection_count.to_i).to eq(6)
    expect(@list.widget.selection_indices.to_a).to eq([1, 2, 3, 4, 5, 6])
    expect(@list.widget.selection.to_a).to eq(["Quebec", "Ontario", "Manitoba", "Saskatchewan", "Alberta", "British Columbia"])
   end
end