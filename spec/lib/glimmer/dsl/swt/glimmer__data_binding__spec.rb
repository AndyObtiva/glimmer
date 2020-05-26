require 'spec_helper'

module GlimmerSpec
  describe "Glimmer Data Binding" do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :name, :age, :adult, :name_selection
        attr_reader :id

        def initialize(id = nil)
          @id = id
        end
      end

      class PersonWithComputedValues
        attr_accessor :first_name, :last_name, :year_of_birth
        def name
          "#{last_name}, #{first_name}"
        end
        def age
          Time.now.year - year_of_birth
        end
      end

      class PersonWithNestedComputedValues
        class Address
          attr_accessor :streets
          def street_count
            streets.count
          end
        end
        attr_accessor :addresses
      end

      class Address
        attr_accessor :street
      end

      class PersonWithNestedProperties
        attr_accessor :address1, :address2
      end

      class PersonWithNestedIndexedProperties
        attr_accessor :addresses, :names
      end

      class ::RedComposite
        include Glimmer::UI::CustomWidget

        body {
          composite(swt_style) {
            background :red
          }
        }
      end

      class ::RedText
        include Glimmer::UI::CustomWidget

        body {
          text(swt_style) {
            background :red
          }
        }
      end

      module ::Red
        class Text
          include Glimmer::UI::CustomWidget

          body {
            red_composite {
              @red_text = red_text {
                # NOOP
              }
            }
          }

          def custom_text=(value)
            @red_text.swt_widget.setText value.to_s
          end

          def custom_text
            @red_text.swt_widget.getText
          end

          def add_observer(observer, attribute_name)
            if attribute_name.to_s == 'custom_text'
              @red_text.add_observer(observer, 'text')
            else
              super
            end
          end
        end
      end
    end

    after(:all) do
      ::Red.send(:remove_const, :Text) if ::Red.const_defined?(:Text)
      %w[
        Person
        PersonWithComputedValues
        PersonWithNestedComputedValues
        Address
        PersonWithNestedProperties
        PersonWithNestedIndexedProperties
        RedComposite
        RedText
        Red
      ].each do |constant|
        Object.send(:remove_const, constant) if Object.const_defined?(constant)
      end
    end

    it "tests text widget data binding string property" do
      person = Person.new
      person.name = "Bruce Ting"

      @target = shell {
        composite {
          @text = text {
            text bind(person, :name)
          }
        }
      }

      expect(@text.swt_widget.getText).to eq("Bruce Ting")

      person.name = "Lady Butterfly"
      expect(@text.swt_widget.getText).to eq("Lady Butterfly")

      @text.swt_widget.setText("Allen Deiley")
      expect(person.name).to eq("Allen Deiley")
    end
    
    context "text widget selection" do
      it "updates text widget selection when hitting key down" do
        person = Person.new
        person.name = "Bruce Ting"
        person.name_selection = Point.new(1,4)
  
        @target = shell {
          composite {
            @text = text {
              text bind(person, :name)
              selection bind(person, :name_selection)
            }
          }
        }
  
        expect(@text.swt_widget.getText).to eq("Bruce Ting")
        expect(@text.swt_widget.getSelection.x).to eq(1)
        expect(@text.swt_widget.getSelection.y).to eq(4)
        
        @text.swt_widget.setSelection(Point.new(2, 4))
        event = Event.new
        event.keyCode = Glimmer::SWT::SWTProxy[:arrow_right]
        event.doit = true
        event.character = 26.chr
        event.display = Glimmer::SWT::DisplayProxy.instance.swt_display
        event.item = @text.swt_widget
        event.widget = @text.swt_widget
        event.type = Glimmer::SWT::SWTProxy[:keydown]
        @text.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:keydown], event)
        
        expect(person.name_selection.x).to eq(2)
        expect(person.name_selection.y).to eq(4)
      end
       
      it "updates text widget selection when clicking mouse down" do
        person = Person.new
        person.name = "Bruce Ting"
        person.name_selection = Point.new(1,4)
  
        @target = shell {
          composite {
            @text = text {
              text bind(person, :name)
              selection bind(person, :name_selection)
            }
          }
        }
  
        expect(@text.swt_widget.getText).to eq("Bruce Ting")
        expect(@text.swt_widget.getSelection.x).to eq(1)
        expect(@text.swt_widget.getSelection.y).to eq(4)
        
        @text.swt_widget.setSelection(Point.new(2, 4))
        event = Event.new
        event.doit = true
        event.display = Glimmer::SWT::DisplayProxy.instance.swt_display
        event.item = @text.swt_widget
        event.widget = @text.swt_widget
        event.type = Glimmer::SWT::SWTProxy[:mousedown]
        @text.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:mousedown], event)
        
        expect(person.name_selection.x).to eq(2)
        expect(person.name_selection.y).to eq(4)
      end    
    end

    it "tests red label custom widget data binding string property" do
      person = Person.new
      person.name = "Bruce Ting"

      person2 = Person.new
      person2.name = "Bruce Ting"

      person3 = Person.new
      person3.name = "Bruce Ting"

      @target = shell {
        composite {
          @red_text = red_text {
            text bind(person, :name)
          }
        }
        red_composite {
          @red_text2 = red_text {
            text bind(person2, :name)
          }
        }
        @red_text3 = red__text {
          custom_text bind(person3, :name)
        }
      }

      expect(@red_text.swt_widget.getText).to eq("Bruce Ting")
      person.name = "Lady Butterfly"
      expect(@red_text.swt_widget.getText).to eq("Lady Butterfly")
      @red_text.swt_widget.setText("Allen Deiley")
      expect(person.name).to eq("Allen Deiley")

      expect(@red_text2.swt_widget.getText).to eq("Bruce Ting")
      person2.name = "Lady Butterfly"
      expect(@red_text2.swt_widget.getText).to eq("Lady Butterfly")
      @red_text2.swt_widget.setText("Allen Deiley")
      expect(person2.name).to eq("Allen Deiley")

      red_text3_widget = @red_text3.swt_widget
      red_text3_widget = red_text3_widget.getChildren.first
      expect(red_text3_widget.getText).to eq("Bruce Ting")
      expect(@red_text3.custom_text).to eq("Bruce Ting")
      person3.name = "Lady Butterfly"
      expect(red_text3_widget.getText).to eq("Lady Butterfly")
      expect(@red_text3.custom_text).to eq("Lady Butterfly")
      red_text3_widget.setText("Allen Deiley")
      expect(person3.name).to eq("Allen Deiley")
      @red_text3.custom_text = "Sean McFaun"
      expect(person3.name).to eq("Sean McFaun")
    end

    it "tests label widget data binding string property" do
      person = Person.new(839728)
      person.name = "Bruce Ting"

      @target = shell {
        composite {
          @label1 = label {
            text bind(person, :id)
          }
          @label2 = label {
            text bind(person, :name)
          }
        }
      }

      expect(@label1.swt_widget.getText).to eq("839728")
      expect(@label2.swt_widget.getText).to eq("Bruce Ting")

      person.name = "Lady Butterfly"
      expect(@label2.swt_widget.getText).to eq("Lady Butterfly")
    end

    it "tests label widget computed value data binding string property" do
      person = PersonWithComputedValues.new
      person.first_name = "Marty"
      person.last_name = "McFly"

      @target = shell {
        composite {
          @label = label {
            text bind(person, :name, computed_by: [:first_name, :last_name])
          }
        }
      }

      expect(@label.swt_widget.getText).to eq("McFly, Marty")

      person.first_name = "Martin"
      expect(@label.swt_widget.getText).to eq("McFly, Martin")

      person.last_name = "MacFly"
      expect(@label.swt_widget.getText).to eq("MacFly, Martin")
    end

    it "tests label widget computed value data binding integer property" do
      person = PersonWithComputedValues.new
      person.year_of_birth = Time.now.year - 40 #TODO TimeCop gem ?

      @target = shell {
        composite {
          @label = label {
            text bind(person, :age, on_write: :to_i, computed_by: :year_of_birth)
          }
        }
      }

      expect(@label.swt_widget.getText).to eq("40")

      person.year_of_birth = Time.now.year - 41
      expect(@label.swt_widget.getText).to eq("41")
    end

    it "tests checkbox widget data binding boolean property" do
      person = Person.new
      person.adult = true

      @target = shell {
        composite {
          @check_box = button(:check) {
            selection bind(person, :adult)
          }
        }
      }

      expect(@check_box.swt_widget.getSelection).to eq(true)

      person.adult = false
      expect(@check_box.swt_widget.getSelection).to eq(false)

      @check_box.swt_widget.setSelection(true)
      @check_box.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.adult).to eq(true)
    end

    it "tests radio widget data binding boolean property" do
      person = Person.new
      person.adult = true

      @target = shell {
        composite {
          @radio = button(:radio) {
            selection bind(person, :adult)
          }
        }
      }

      expect(@radio.swt_widget.getSelection).to eq(true)

      person.adult = false
      expect(@radio.swt_widget.getSelection).to eq(false)

      @radio.swt_widget.setSelection(true)
      @radio.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.adult).to eq(true)
    end

    it "tests spinner widget data binding integer selection property" do
      person = Person.new
      person.age = 17

      @target = shell {
        composite {
          @spinner = spinner {
            selection bind(person, :age)
          }
        }
      }

      expect(@spinner.swt_widget.getSelection).to eq(17)

      person.age = 20
      expect(@spinner.swt_widget.getSelection).to eq(20)

      @spinner.swt_widget.setSelection(34)
      @spinner.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.age).to eq(34)
    end

    it "tests menu item widget data binding boolean selection property" do
      person = Person.new
      person.adult = false

      @target = shell {
        menu_bar {
          menu {
            @menu_item = menu_item(:radio) {
              text 'Adult'
              selection bind(person, :adult)
            }
          }
        }
      }

      expect(@menu_item.swt_widget.getSelection).to eq(false)

      person.adult = true
      expect(@menu_item.swt_widget.getSelection).to eq(true)

      @menu_item.swt_widget.setSelection(false)
      @menu_item.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.adult).to eq(false)
    end

    it "tests menu item widget ready-only data binding of boolean selection property" do
      person = Person.new
      person.age = 17

      @target = shell {
        menu_bar {
          menu {
            @menu_item = menu_item(:radio) {
              text 'Adult'
              selection bind(person, :age, read_only: true) {|a| a >= 18}
            }
          }
        }
      }

      expect(@menu_item.swt_widget.getSelection).to eq(false)

      person.age = 20
      expect(@menu_item.swt_widget.getSelection).to eq(true)

      @menu_item.swt_widget.setSelection(false)
      @menu_item.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.age).to eq(20)
    end

    it "tests menu item widget one-direction-only data binding of boolean enabled property" do
      person = Person.new
      person.adult = false

      @target = shell {
        menu_bar {
          menu {
            @menu_item = menu_item(:radio) {
              text 'Smoker'
              enabled bind(person, :adult)
            }
          }
        }
      }

      expect(@menu_item.swt_widget.getEnabled).to eq(false)

      person.adult = true
      expect(@menu_item.swt_widget.getEnabled).to eq(true)

      @menu_item.swt_widget.setEnabled(false)
      @menu_item.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.adult).to eq(true)
    end

    unless ENV['CI'].to_s.downcase == 'true'
      context 'focus' do
        after do
          if @target
            @target.async_exec do
              @target.dispose
            end
            @target.open
          end
        end
  
        it 'tests widget data binding focus' do
          person = Person.new
          expect(person.adult).to be_nil
  
          @target = shell {
            alpha 0 # keep invisible while running specs
            @text1 = text {
              text "First one is focused by default"
            }
            @text2 = text {
              focus bind(person, :adult)
              text "Not focused"
            }
          }
  
          @target.async_exec do
            expect(@text1.swt_widget.isFocusControl).to eq(true)
            expect(@text2.swt_widget.isFocusControl).to eq(false)
  
            person.adult = true
  
            expect(@text1.swt_widget.isFocusControl).to eq(false)
            expect(@text2.swt_widget.isFocusControl).to eq(true)
  
            expect(@text1.swt_widget.setFocus).to eq(true)
  
            expect(person.adult).to eq(false)
  
            expect(@text2.swt_widget.setFocus).to eq(true)
  
            expect(person.adult).to eq(true)
          end
  
          # TODO test data binding in the other direction (from widget to model)
        end
      end
    end

    it "tests widget data binding enablement" do
      person = Person.new
      person.adult = true

      @target = shell {
        composite {
          @text = text {
            enabled bind(person, :adult)
          }
        }
      }

      expect(@text.swt_widget.isEnabled).to eq(true)

      person.adult = false
      expect(@text.swt_widget.isEnabled).to eq(false)
    end

    it "tests multiple widget data binding enablement to same model property" do
      person = Person.new
      person.adult = true

      @target = shell {
        composite {
          @text = text {
            enabled bind(person, :adult)
          }
          @text2 = text {
            enabled bind(person, :adult)
          }
          @text3 = text {
            enabled bind(person, :adult)
          }
        }
      }

      expect(@text.swt_widget.isEnabled).to eq(true)
      expect(@text2.swt_widget.isEnabled).to eq(true)
      expect(@text3.swt_widget.isEnabled).to eq(true)

      person.adult = false
      expect(@text.swt_widget.isEnabled).to eq(false)
      expect(@text2.swt_widget.isEnabled).to eq(false)
      expect(@text3.swt_widget.isEnabled).to eq(false)
    end

    it "tests multiple widget data bindings to different model properties" do
      person = Person.new
      person.name = "Nancy"
      person.age = 15
      person.adult = true

      @target = shell {
        composite {
          @label = label {
            text bind(person, :name)
          }
          @check_box = button(:check) {
            selection bind(person, :adult)
          }
        }
      }

      expect(@label.swt_widget.getText).to eq("Nancy")
      expect(@check_box.swt_widget.getSelection).to eq(true)

      person.name = "Drew"
      expect(@label.swt_widget.getText).to eq("Drew")

      person.adult = false
      expect(@check_box.swt_widget.getSelection).to eq(false)

      @check_box.swt_widget.setSelection(true)
      @check_box.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.adult).to eq(true)
    end

    context "nested data binding" do

      it "tests text widget data binding to nested string property" do
        person = PersonWithNestedProperties.new
        person.address1 = Address.new
        person.address2 = Address.new

        person.address1.street = "20 Naper Ave"

        person.address2.street = "101 Confession St"

        @target = shell {
          composite {
            @address1_street_text_widget = text {
              text bind(person, "address1.street")
            }
          }
          composite {
            @address2_street_text_widget = text {
              text bind(person, "address2.street")
            }
          }
        }

        expect(@address1_street_text_widget.swt_widget.getText).to eq("20 Naper Ave")

        expect(@address2_street_text_widget.swt_widget.getText).to eq("101 Confession St")

        @address1_street_text_widget.swt_widget.setText "101 Confession St"

        @address2_street_text_widget.swt_widget.setText "20 Naper Ave"

        expect(person.address1.street).to eq("101 Confession St")

        expect(person.address2.street).to eq("20 Naper Ave")

        person.address1.street = "123 Main St"

        person.address2.street = "100 Park Ave"

        expect(@address1_street_text_widget.swt_widget.getText).to eq("123 Main St")

        expect(@address2_street_text_widget.swt_widget.getText).to eq("100 Park Ave")

        person.address2 = person.address1

        expect(@address2_street_text_widget.swt_widget.getText).to eq("123 Main St")

        person.address2 = nil

        expect(@address2_street_text_widget.swt_widget.getText).to eq("")

        person.address2 = Address.new

        person.address2.street = "101 Confession St"

        expect(@address2_street_text_widget.swt_widget.getText).to eq("101 Confession St")

        person.address2.street = "123 Main St"

        expect(@address2_street_text_widget.swt_widget.getText).to eq("123 Main St")
      end

      it "tests text widget data binding to nested indexed string property" do
        person = PersonWithNestedIndexedProperties.new

        @target = shell {
          composite {
            @name1 = text {
              text bind(person, "names[0]")
            }
            @address1_street_text_widget = text {
              text bind(person, "addresses[0].street")
            }
          }
          composite {
            @name2 = text {
              text bind(person, "names[1]")
            }
            @address2_street_text_widget = text {
              text bind(person, "addresses[1].street")
            }
          }
        }

        expect(@name1.swt_widget.getText).to eq("")
        expect(@address1_street_text_widget.swt_widget.getText).to eq("")

        expect(@name2.swt_widget.getText).to eq("")
        expect(@address2_street_text_widget.swt_widget.getText).to eq("")

        person.names = []
        person.names[0] = 'Robert'
        person.names[1] = 'Bob'

        person.addresses = []
        person.addresses[0] = Address.new
        person.addresses[1] = Address.new

        person.addresses[0].street = "20 Naper Ave"

        person.addresses[1].street = "101 Confession St"

        expect(@name1.swt_widget.getText).to eq("Robert")
        expect(@address1_street_text_widget.swt_widget.getText).to eq("20 Naper Ave")

        expect(@name2.swt_widget.getText).to eq("Bob")
        expect(@address2_street_text_widget.swt_widget.getText).to eq("101 Confession St")

        @name1.swt_widget.setText "Roberto"
        @address1_street_text_widget.swt_widget.setText "101 Confession St"

        @name2.swt_widget.setText "Bobo"
        @address2_street_text_widget.swt_widget.setText "20 Naper Ave"

        expect(person.names[0]).to eq("Roberto")
        expect(person.addresses[0].street).to eq("101 Confession St")

        expect(person.names[1]).to eq("Bobo")
        expect(person.addresses[1].street).to eq("20 Naper Ave")

        person.names[0] = "Robertissimo"
        person.addresses[0].street = "123 Main St"

        person.names[1] = "Bobissimo"
        person.addresses[1].street = "100 Park Ave"

        expect(@name1.swt_widget.getText).to eq("Robertissimo")
        expect(@address1_street_text_widget.swt_widget.getText).to eq("123 Main St")

        expect(@name2.swt_widget.getText).to eq("Bobissimo")
        expect(@address2_street_text_widget.swt_widget.getText).to eq("100 Park Ave")

        person.names[1] = person.names[0]
        original_address2 = person.addresses[1]
        person.addresses[1] = person.addresses[0]

        expect(@name2.swt_widget.getText).to eq("Robertissimo")
        expect(@address2_street_text_widget.swt_widget.getText).to eq("123 Main St")

        # Ensure data-binding observers are removed when address value changed
        original_address2.street = '838 Newman'
        expect(@address2_street_text_widget.swt_widget.getText).to_not eq('838 Newman')
        person.addresses[1].street = '838 Newman'
        expect(@address2_street_text_widget.swt_widget.getText).to eq('838 Newman')

        person.names[1] = nil
        person.addresses[1] = nil

        expect(@name2.swt_widget.getText).to eq("")
        expect(@address2_street_text_widget.swt_widget.getText).to eq("")

        person.addresses[1] = Address.new

        person.addresses[1].street = "101 Confession St"

        expect(@address2_street_text_widget.swt_widget.getText).to eq("101 Confession St")

        person.addresses[1].street = "123 Main St"

        expect(@address2_street_text_widget.swt_widget.getText).to eq("123 Main St")

        # test removal of observers on severed nested chains
        old_address2 = person.addresses[1]
        expect(old_address2.property_observer_list('street').to_a.empty?).to be_falsey

        person.addresses[1] = Address.new
        expect(old_address2.property_observer_list('street').to_a.empty?).to be_truthy

        old_address2 = person.addresses[1]
        expect(old_address2.property_observer_list('street').to_a.empty?).to be_falsey

        person.addresses.delete(old_address2)
        expect(old_address2.property_observer_list('street').to_a.empty?).to be_truthy

        person.addresses << old_address2
        expect(old_address2.property_observer_list('street').to_a.empty?).to be_falsey

        person.addresses.delete_at(1)
        expect(old_address2.property_observer_list('street').to_a.empty?).to be_truthy

        person.addresses << old_address2

        old_address1 = person.addresses[0]
        expect(old_address1.property_observer_list('street').to_a.empty?).to be_falsey

        expect(old_address2.property_observer_list('street').to_a.empty?).to be_falsey

        person.addresses.clear

        expect(old_address1.property_observer_list('street').to_a.empty?).to be_truthy

        expect(old_address2.property_observer_list('street').to_a.empty?).to be_truthy

        person.addresses << old_address1
        person.addresses << old_address2

        old_addresses = person.addresses
        old_address1 = person.addresses[0]
        old_address2 = person.addresses[1]
        expect(old_addresses.property_observer_list.to_a.empty?).to be_falsey
        expect(old_address1.property_observer_list('street').to_a.empty?).to be_falsey

        expect(old_address2.property_observer_list('street').to_a.empty?).to be_falsey

        person.addresses = []

        expect(old_addresses.property_observer_list.to_a.empty?).to be_truthy
        expect(old_address1.property_observer_list('street').to_a.empty?).to be_truthy

        expect(old_address2.property_observer_list('street').to_a.empty?).to be_truthy
      end

      it "tests label widget nested computed value data binding string property" do
        person = PersonWithNestedComputedValues.new
        person.addresses = []
        person.addresses[0] = PersonWithNestedComputedValues::Address.new
        person.addresses[1] = PersonWithNestedComputedValues::Address.new
        person.addresses[0].streets = ['123 Main', '234 Park']
        person.addresses[1].streets = ['456 Milwaukee', '789 Superior', '983 Owen']

        @target = shell {
          composite {
            @label1 = label {
              text bind(person, 'addresses[0].street_count', computed_by: ['addresses[0].streets'])
            }
            @label2 = label {
              text bind(person, 'addresses[1].street_count', computed_by: ['addresses[1].streets'])
            }
          }
        }

        expect(@label1.swt_widget.getText).to eq("2")
        expect(@label2.swt_widget.getText).to eq("3")

        person.addresses[0].streets = []
        expect(@label1.swt_widget.getText).to eq("0")

        person.addresses[0].streets = ['8376 Erie']
        expect(@label1.swt_widget.getText).to eq("1")

        person.addresses[0].streets.clear
        expect(@label1.swt_widget.getText).to eq("0")

        person.addresses[1].streets << '923 Huron'
        expect(@label2.swt_widget.getText).to eq("4")
      end

      it 'removes observers upon disposing a widget' do
        person = Person.new
        person.adult = true

        @target = shell {
          composite {
            @radio = button(:radio) {
              selection bind(person, :adult)
            }
          }
        }

        expect(@radio.swt_widget.getSelection).to eq(true)
        @radio.swt_widget.dispose
        expect {person.adult = false}.to_not raise_error
      end

      it 'removes nested/indexed observers upon disposing a widget' do
        person = PersonWithNestedIndexedProperties.new
        person.addresses = []
        person.addresses[0] = Address.new
        person.addresses[1] = Address.new

        @target = shell {
          composite {
            @address1_street_text_widget = text {
              text bind(person, "addresses[0].street")
            }
            @address1b_street_text_widget = text {
              text bind(person, "addresses[0].street")
            }
            @address2_street_text_widget = text {
              text bind(person, "addresses[1].street")
            }
          }
        }

        @address1_street_text_widget.swt_widget.dispose
        expect {person.addresses[0].street = "123 Main St"}.to_not raise_error
        expect(@address1b_street_text_widget.swt_widget.getText).to eq("123 Main St")

        person.addresses[1].street = "79 Park Ave"
        expect(@address2_street_text_widget.swt_widget.getText).to eq("79 Park Ave")
      end
    end
  end
end
