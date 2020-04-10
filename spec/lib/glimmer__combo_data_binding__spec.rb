require "spec_helper"

module GlimmerSpec
  describe "Glimmer Combo Data Binding" do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :country, :country_options

        def initialize
          self.country_options=["", "Canada", "US", "Mexico"]
        end
      end

      class ::RedCombo
        include Glimmer::UI::CustomWidget

        body {
          combo(swt_style) {
            background :red
          }
        }
      end
    end

    after(:all) do
      Object.send(:remove_const, :Person) if Object.const_defined?(:Person)
      Object.send(:remove_const, :RedCombo) if Object.const_defined?(:RedCombo)
    end

    it "tests data binding selection property" do
      person = Person.new

      @target = shell {
        @combo = combo {
          selection bind(person, :country)
        }
      }

      expect(@combo.swt_widget.item_count).to eq(4)
      expect(@combo.swt_widget.selection_index).to eq(-1)
      expect(@combo.swt_widget.text).to eq("")

      person.country = "Canada"

      expect(@combo.swt_widget.text).to eq("Canada")

      person.country_options << "France"

      expect(@combo.swt_widget.item_count).to eq(5)

      person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]

      expect(@combo.swt_widget.item_count).to eq(6)

      person.country_options << "Italy"
      person.country_options << "Germany"
      person.country_options << "Australia"

      expect(@combo.swt_widget.item_count).to eq(9)

      expect(@combo.swt_widget.text).to eq("")

      @combo.swt_widget.select(2)
      @combo.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.country).to eq("US")

      person.country = "Canada"

      expect(@combo.swt_widget.text).to eq("Canada")

      person.country = "Russia"

      expect(@combo.swt_widget.text).to eq("Russia")

      person.country = ""

      expect(@combo.swt_widget.text).to eq("")

      person.country = "Japan"

      expect(@combo.swt_widget.text).to eq("Japan")
    end

    it "tests read only widget data binding selection property" do
      person = Person.new
      person.country = "Canada"

      @target = shell {
        @combo = combo(:read_only) {
          selection bind(person, :country)
        }
      }

      expect(@combo.swt_widget.item_count).to eq(4)
      expect(@combo.swt_widget.text).to eq("Canada")

      person.country_options << "France"

      expect(@combo.swt_widget.item_count).to eq(5)

      person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]

      expect(@combo.swt_widget.item_count).to eq(6)

      person.country_options << "Italy"
      person.country_options << "Germany"
      person.country_options << "Australia"

      expect(@combo.swt_widget.item_count).to eq(9)

      expect(@combo.swt_widget.text).to eq("")

      @combo.swt_widget.select(8)
      @combo.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.country).to eq("Australia")

      person.country = "Canada"

      expect(@combo.swt_widget.text).to eq("Canada")

      person.country = "Russia"

      expect(@combo.swt_widget.text).to eq("Russia")

      person.country = ""

      expect(@combo.swt_widget.text).to eq("")

      person.country = "Japan"

      expect(@combo.swt_widget.text).to eq("")
    end

    it "tests data binding selection property on custom widget combo" do
      person = Person.new

      @target = shell {
        @combo = red_combo {
          selection bind(person, :country)
        }
      }

      expect(@combo.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@combo.swt_widget.item_count).to eq(4)
      expect(@combo.swt_widget.selection_index).to eq(-1)
      expect(@combo.swt_widget.text).to eq("")
    end
  end
end
