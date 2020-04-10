require "spec_helper"

module GlimmerSpec
  describe "Glimmer List Data Binding" do
    include Glimmer

    before(:all) do
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

      class ::RedList
        include Glimmer::UI::CustomWidget
        body {
          list(swt_style) {
            background :red
          }
        }
      end
    end

    after(:all) do
      Object.send(:remove_const, :Person) if Object.const_defined?(:Person)
      Object.send(:remove_const, :RedList) if Object.const_defined?(:RedList)
    end

    it "tests single selection property" do
      person = Person.new

      @target = shell {
        @list = list {
          selection bind(person, :country)
        }
      }

      expect(@list.swt_widget.item_count).to eq(4)
      expect(@list.swt_widget.selection_index).to eq(-1)
      expect(@list.swt_widget.selection.to_a).to eq([])

      @list.swt_widget.select(1)
      @list.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.country).to eq("Canada")

      person.country_options << "France"

      expect(@list.swt_widget.item_count).to eq(5)

      person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]

      expect(@list.swt_widget.item_count).to eq(6)

      person.country_options << "Italy"
      person.country_options << "Germany"
      person.country_options << "Australia"

      expect(@list.swt_widget.item_count).to eq(9)

      person.country = "Canada"

      expect(@list.swt_widget.selection_index).to eq(1)
      expect(@list.swt_widget.selection.to_a).to eq(["Canada"])

      person.country = "Russia"

      expect(@list.swt_widget.selection_index).to eq(4)
      expect(@list.swt_widget.selection.to_a).to eq(["Russia"])

      person.country = ""

      expect(@list.swt_widget.selection_index).to eq(0)
      expect(@list.swt_widget.selection.to_a).to eq([""])

      person.country = "Japan"

      expect(@list.swt_widget.selection_index).to eq(0)
      expect(@list.swt_widget.selection.to_a).to eq([""])

      @list.swt_widget.select(2)
      @list.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
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

      expect(@list.swt_widget.item_count).to eq(4)
      expect(@list.swt_widget.selection_index).to eq(1)
      expect(@list.swt_widget.selection.to_a).to eq(["Canada"])

      @list.swt_widget.select(2)
      @list.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.country).to eq("US")

      person.country_options << "France"

      expect(@list.swt_widget.item_count).to eq(5)

      person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]

      expect(@list.swt_widget.item_count).to eq(6)

      person.country_options << "Italy"
      person.country_options << "Germany"
      person.country_options << "Australia"

      expect(@list.swt_widget.item_count).to eq(9)

      person.country = "Canada"

      expect(@list.swt_widget.selection_index).to eq(1)
      expect(@list.swt_widget.selection.to_a).to eq(["Canada"])

      person.country = "Russia"

      expect(@list.swt_widget.selection_index).to eq(4)
      expect(@list.swt_widget.selection.to_a).to eq(["Russia"])

      person.country = ""

      expect(@list.swt_widget.selection_index).to eq(0)
      expect(@list.swt_widget.selection.to_a).to eq([""])

      person.country = "Japan"

      expect(@list.swt_widget.selection_index).to eq(0)
      expect(@list.swt_widget.selection.to_a).to eq([""])
    end

    it "tests multi selection property" do
      person = Person.new

      @target = shell {
        @list = list(:multi) {
          selection bind(person, :provinces)
        }
      }

      expect(@list.swt_widget.selection_count.to_i).to eq(0)
      expect(@list.swt_widget.selection.to_a).to eq([])

      @list.swt_widget.select(1)
      @list.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.provinces).to eq(["Quebec"])

      @list.swt_widget.select(2)
      @list.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.provinces).to eq(["Quebec", "Ontario"])

      person.provinces=["Ontario", "Manitoba", "Alberta"]

      expect(@list.swt_widget.selection_count.to_i).to eq(3)
      expect(@list.swt_widget.selection_indices.to_a).to eq([2, 3, 5])
      expect(@list.swt_widget.selection.to_a).to eq(["Ontario", "Manitoba", "Alberta"])

      person.provinces << "Quebec"
      person.provinces << "Saskatchewan"
      person.provinces << "British Columbia"

      expect(@list.swt_widget.selection_count.to_i).to eq(6)
      expect(@list.swt_widget.selection_indices.to_a).to eq([1, 2, 3, 4, 5, 6])
      expect(@list.swt_widget.selection.to_a).to eq(["Quebec", "Ontario", "Manitoba", "Saskatchewan", "Alberta", "British Columbia"])
    end

    it "tests multi selection property with model preinitialized" do
      person = Person.new
      person.provinces = []

      @target = shell {
        @list = list(:multi) {
          selection bind(person, :provinces)
        }
      }

      expect(@list.swt_widget.selection_count.to_i).to eq(0)
      expect(@list.swt_widget.selection.to_a).to eq([])

      @list.swt_widget.select(1)
      @list.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.provinces).to eq(["Quebec"])

      @list.swt_widget.select(2)
      @list.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.provinces).to eq(["Quebec", "Ontario"])

      person.provinces=["Ontario", "Manitoba", "Alberta"]

      expect(@list.swt_widget.selection_count.to_i).to eq(3)
      expect(@list.swt_widget.selection_indices.to_a).to eq([2, 3, 5])
      expect(@list.swt_widget.selection.to_a).to eq(["Ontario", "Manitoba", "Alberta"])

      person.provinces << "Quebec"
      person.provinces << "Saskatchewan"
      person.provinces << "British Columbia"

      expect(@list.swt_widget.selection_count.to_i).to eq(6)
      expect(@list.swt_widget.selection_indices.to_a).to eq([1, 2, 3, 4, 5, 6])
      expect(@list.swt_widget.selection.to_a).to eq(["Quebec", "Ontario", "Manitoba", "Saskatchewan", "Alberta", "British Columbia"])

      old_provinces = person.provinces
      expect(old_provinces.property_observer_list.to_a.empty?).to be_falsey
      person.provinces = ["Quebec", "Saskatchewan", "British Columbia"]
      expect(@list.swt_widget.selection_count.to_i).to eq(3)
      expect(@list.swt_widget.selection.to_a).to eq(["Quebec", "Saskatchewan", "British Columbia"])

      # old binding doesn't observe anymore
      old_provinces << "New Brunswick"
      expect(@list.swt_widget.selection_count.to_i).to eq(3)
      expect(@list.swt_widget.selection.to_a).to eq(["Quebec", "Saskatchewan", "British Columbia"])
      expect(old_provinces.property_observer_list.to_a.empty?).to be_truthy
    end

    it "tests single selection property with a custom widget list" do
      person = Person.new

      @target = shell {
        @list = red_list {
          selection bind(person, :country)
        }
      }

      expect(@list.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@list.swt_widget.item_count).to eq(4)
      expect(@list.swt_widget.selection_index).to eq(-1)
      expect(@list.swt_widget.selection.to_a).to eq([])
    end
  end
end
