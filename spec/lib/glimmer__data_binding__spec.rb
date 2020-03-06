require 'spec_helper'

describe "Glimmer Data Binding" do
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
    attr_accessor :name, :age, :adult
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

  class Address
    attr_accessor :street, :city, :state, :zip
  end

  class PersonWithNestedProperties
    attr_accessor :address1, :address2
  end

  class PersonWithNestedIndexedProperties
    attr_accessor :addresses, :names
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

    expect(@text.widget.getText).to eq("Bruce Ting")

    person.name = "Lady Butterfly"
    expect(@text.widget.getText).to eq("Lady Butterfly")

    @text.widget.setText("Allen Cork")
    expect(person.name).to eq("Allen Cork")
  end

  it "tests text widget data binding fixnum property" do
    person = Person.new
    person.age = 15

    @target = shell {
      composite {
        @text = text {
          text bind(person, :age, :fixnum)
        }
      }
    }

    expect(@text.widget.getText).to eq("15")

    person.age = 27
    expect(@text.widget.getText).to eq("27")

    @text.widget.setText("30")
    expect(person.age).to eq(30)
  end

  it "tests label widget data binding string property" do
    person = Person.new
    person.name = "Bruce Ting"

    @target = shell {
      composite {
        @label = label {
          text bind(person, :name)
        }
      }
    }

    expect(@label.widget.getText).to eq("Bruce Ting")

    person.name = "Lady Butterfly"
    expect(@label.widget.getText).to eq("Lady Butterfly")
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

    expect(@label.widget.getText).to eq("McFly, Marty")

    person.first_name = "Martin"
    expect(@label.widget.getText).to eq("McFly, Martin")

    person.last_name = "MacFly"
    expect(@label.widget.getText).to eq("MacFly, Martin")
  end

  it "tests label widget computed value data binding fixnum property" do
    person = PersonWithComputedValues.new
    person.year_of_birth = Time.now.year - 40 #TODO TimeCop gem ?

    @target = shell {
      composite {
        @label = label {
          text bind(person, :age, :fixnum, computed_by: [:year_of_birth])
        }
      }
    }

    expect(@label.widget.getText).to eq("40")

    person.year_of_birth = Time.now.year - 41
    expect(@label.widget.getText).to eq("41")
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

    expect(@check_box.widget.getSelection).to eq(true)

    person.adult = false
    expect(@check_box.widget.getSelection).to eq(false)

    @check_box.widget.setSelection(true)
    @check_box.widget.notifyListeners(SWT::Selection, nil)
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

    expect(@radio.widget.getSelection).to eq(true)

    person.adult = false
    expect(@radio.widget.getSelection).to eq(false)

    @radio.widget.setSelection(true)
    @radio.widget.notifyListeners(SWT::Selection, nil)
    expect(person.adult).to eq(true)
  end

   it "tests spinner widget data binding fixnum property" do
    person = Person.new
    person.age = 17

    @target = shell {
      composite {
        @spinner = spinner {
          selection bind(person, :age)
        }
      }
    }

    expect(@spinner.widget.getSelection).to eq(17)

    person.age = 20
    expect(@spinner.widget.getSelection).to eq(20)

    @spinner.widget.setSelection(34)
    @spinner.widget.notifyListeners(SWT::Selection, nil)
    expect(person.age).to eq(34)
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

    expect(@text.widget.isEnabled).to eq(true)

    person.adult = false
    expect(@text.widget.isEnabled).to eq(false)
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

    expect(@text.widget.isEnabled).to eq(true)
    expect(@text2.widget.isEnabled).to eq(true)
    expect(@text3.widget.isEnabled).to eq(true)

    person.adult = false
    expect(@text.widget.isEnabled).to eq(false)
    expect(@text2.widget.isEnabled).to eq(false)
    expect(@text3.widget.isEnabled).to eq(false)
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
        @text = text {
          text bind(person, :age, :fixnum)
        }
        @check_box = button(:check) {
          selection bind(person, :adult)
        }
      }
    }

    expect(@label.widget.getText).to eq("Nancy")
    expect(@text.widget.getText).to eq("15")
    expect(@check_box.widget.getSelection).to eq(true)

    person.name = "Drew"
    expect(@label.widget.getText).to eq("Drew")

    person.age = 27
    expect(@text.widget.getText).to eq("27")

    person.adult = false
    expect(@check_box.widget.getSelection).to eq(false)

    @text.widget.setText("30")
    expect(person.age).to eq(30)

    @check_box.widget.setSelection(true)
    @check_box.widget.notifyListeners(SWT::Selection, nil)
    expect(person.adult).to eq(true)
  end

  context "nested data binding" do

    it "tests text widget data binding to nested string property" do
      person = PersonWithNestedProperties.new
      person.address1 = Address.new
      person.address2 = Address.new

      person.address1.street = "20 Naper Ave"
      person.address1.city = "Indianapolis"
      person.address1.state = "IN"
      person.address1.zip = "46183"

      person.address2.street = "101 Confession St"
      person.address2.city = "Denver"
      person.address2.state = "CO"
      person.address2.zip = "80014"

      @target = shell {
        composite {
          @address1_street_text_widget = text {
            text bind(person, "address1.street")
          }
          @address1_city_text_widget = text {
            text bind(person, "address1.city")
          }
          @address1_state_text_widget = text {
            text bind(person, "address1.state")
          }
          @address1_zip_text_widget = text {
            text bind(person, "address1.zip")
          }
        }
        composite {
          @address2_street_text_widget = text {
            text bind(person, "address2.street")
          }
          @address2_city_text_widget = text {
            text bind(person, "address2.city")
          }
          @address2_state_text_widget = text {
            text bind(person, "address2.state")
          }
          @address2_zip_text_widget = text {
            text bind(person, "address2.zip")
          }
        }
      }

      expect(@address1_street_text_widget.widget.getText).to eq("20 Naper Ave")
      expect(@address1_city_text_widget.widget.getText).to eq("Indianapolis")
      expect(@address1_state_text_widget.widget.getText).to eq("IN")
      expect(@address1_zip_text_widget.widget.getText).to eq("46183")

      expect(@address2_street_text_widget.widget.getText).to eq("101 Confession St")
      expect(@address2_city_text_widget.widget.getText).to eq("Denver")
      expect(@address2_state_text_widget.widget.getText).to eq("CO")
      expect(@address2_zip_text_widget.widget.getText).to eq("80014")

      @address1_street_text_widget.widget.setText "101 Confession St"
      @address1_city_text_widget.widget.setText "Denver"
      @address1_state_text_widget.widget.setText "CO"
      @address1_zip_text_widget.widget.setText "80014"

      @address2_street_text_widget.widget.setText "20 Naper Ave"
      @address2_city_text_widget.widget.setText "Indianapolis"
      @address2_state_text_widget.widget.setText "IN"
      @address2_zip_text_widget.widget.setText "46183"

      expect(person.address1.street).to eq("101 Confession St")
      expect(person.address1.city).to eq("Denver")
      expect(person.address1.state).to eq("CO")
      expect(person.address1.zip).to eq("80014")

      expect(person.address2.street).to eq("20 Naper Ave")
      expect(person.address2.city).to eq("Indianapolis")
      expect(person.address2.state).to eq("IN")
      expect(person.address2.zip).to eq("46183")

      person.address1.street = "123 Main St"
      person.address1.city = "Chicago"
      person.address1.state = "IL"
      person.address1.zip = "60654"

      person.address2.street = "100 Park Ave"
      person.address2.city = "San Diego"
      person.address2.state = "CA"
      person.address2.zip = "92014"

      expect(@address1_street_text_widget.widget.getText).to eq("123 Main St")
      expect(@address1_city_text_widget.widget.getText).to eq("Chicago")
      expect(@address1_state_text_widget.widget.getText).to eq("IL")
      expect(@address1_zip_text_widget.widget.getText).to eq("60654")

      expect(@address2_street_text_widget.widget.getText).to eq("100 Park Ave")
      expect(@address2_city_text_widget.widget.getText).to eq("San Diego")
      expect(@address2_state_text_widget.widget.getText).to eq("CA")
      expect(@address2_zip_text_widget.widget.getText).to eq("92014")

      person.address2 = person.address1

      expect(@address2_street_text_widget.widget.getText).to eq("123 Main St")
      expect(@address2_city_text_widget.widget.getText).to eq("Chicago")
      expect(@address2_state_text_widget.widget.getText).to eq("IL")
      expect(@address2_zip_text_widget.widget.getText).to eq("60654")

      person.address2 = nil

      expect(@address2_street_text_widget.widget.getText).to eq("")
      expect(@address2_city_text_widget.widget.getText).to eq("")
      expect(@address2_state_text_widget.widget.getText).to eq("")
      expect(@address2_zip_text_widget.widget.getText).to eq("")

      person.address2 = Address.new

      person.address2.street = "101 Confession St"
      person.address2.city = "Denver"
      person.address2.state = "CO"
      person.address2.zip = "80014"

      expect(@address2_street_text_widget.widget.getText).to eq("101 Confession St")
      expect(@address2_city_text_widget.widget.getText).to eq("Denver")
      expect(@address2_state_text_widget.widget.getText).to eq("CO")
      expect(@address2_zip_text_widget.widget.getText).to eq("80014")

      person.address2.street = "123 Main St"
      person.address2.city = "Chicago"
      person.address2.state = "IL"
      person.address2.zip = "60654"

      expect(@address2_street_text_widget.widget.getText).to eq("123 Main St")
      expect(@address2_city_text_widget.widget.getText).to eq("Chicago")
      expect(@address2_state_text_widget.widget.getText).to eq("IL")
      expect(@address2_zip_text_widget.widget.getText).to eq("60654")
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
          @address1_city_text_widget = text {
            text bind(person, "addresses[0].city")
          }
          @address1_state_text_widget = text {
            text bind(person, "addresses[0].state")
          }
          @address1_zip_text_widget = text {
            text bind(person, "addresses[0].zip")
          }
        }
        composite {
          @name2 = text {
            text bind(person, "names[1]")
          }
          @address2_street_text_widget = text {
            text bind(person, "addresses[1].street")
          }
          @address2_city_text_widget = text {
            text bind(person, "addresses[1].city")
          }
          @address2_state_text_widget = text {
            text bind(person, "addresses[1].state")
          }
          @address2_zip_text_widget = text {
            text bind(person, "addresses[1].zip")
          }
        }
      }

      expect(@name1.widget.getText).to eq("")
      expect(@address1_street_text_widget.widget.getText).to eq("")
      expect(@address1_city_text_widget.widget.getText).to eq("")
      expect(@address1_state_text_widget.widget.getText).to eq("")
      expect(@address1_zip_text_widget.widget.getText).to eq("")

      expect(@name2.widget.getText).to eq("")
      expect(@address2_street_text_widget.widget.getText).to eq("")
      expect(@address2_city_text_widget.widget.getText).to eq("")
      expect(@address2_state_text_widget.widget.getText).to eq("")
      expect(@address2_zip_text_widget.widget.getText).to eq("")

      person.names = []
      person.names[0] = 'Robert'
      person.names[1] = 'Bob'

      person.addresses = []
      person.addresses[0] = Address.new
      person.addresses[1] = Address.new

      person.addresses[0].street = "20 Naper Ave"
      person.addresses[0].city = "Indianapolis"
      person.addresses[0].state = "IN"
      person.addresses[0].zip = "46183"

      person.addresses[1].street = "101 Confession St"
      person.addresses[1].city = "Denver"
      person.addresses[1].state = "CO"
      person.addresses[1].zip = "80014"

      expect(@name1.widget.getText).to eq("Robert")
      expect(@address1_street_text_widget.widget.getText).to eq("20 Naper Ave")
      expect(@address1_city_text_widget.widget.getText).to eq("Indianapolis")
      expect(@address1_state_text_widget.widget.getText).to eq("IN")
      expect(@address1_zip_text_widget.widget.getText).to eq("46183")

      expect(@name2.widget.getText).to eq("Bob")
      expect(@address2_street_text_widget.widget.getText).to eq("101 Confession St")
      expect(@address2_city_text_widget.widget.getText).to eq("Denver")
      expect(@address2_state_text_widget.widget.getText).to eq("CO")
      expect(@address2_zip_text_widget.widget.getText).to eq("80014")

      @name1.widget.setText "Roberto"
      @address1_street_text_widget.widget.setText "101 Confession St"
      @address1_city_text_widget.widget.setText "Denver"
      @address1_state_text_widget.widget.setText "CO"
      @address1_zip_text_widget.widget.setText "80014"

      @name2.widget.setText "Bobo"
      @address2_street_text_widget.widget.setText "20 Naper Ave"
      @address2_city_text_widget.widget.setText "Indianapolis"
      @address2_state_text_widget.widget.setText "IN"
      @address2_zip_text_widget.widget.setText "46183"

      expect(person.names[0]).to eq("Roberto")
      expect(person.addresses[0].street).to eq("101 Confession St")
      expect(person.addresses[0].city).to eq("Denver")
      expect(person.addresses[0].state).to eq("CO")
      expect(person.addresses[0].zip).to eq("80014")

      expect(person.names[1]).to eq("Bobo")
      expect(person.addresses[1].street).to eq("20 Naper Ave")
      expect(person.addresses[1].city).to eq("Indianapolis")
      expect(person.addresses[1].state).to eq("IN")
      expect(person.addresses[1].zip).to eq("46183")

      person.names[0] = "Robertissimo"
      person.addresses[0].street = "123 Main St"
      person.addresses[0].city = "Chicago"
      person.addresses[0].state = "IL"
      person.addresses[0].zip = "60654"

      person.names[1] = "Bobissimo"
      person.addresses[1].street = "100 Park Ave"
      person.addresses[1].city = "San Diego"
      person.addresses[1].state = "CA"
      person.addresses[1].zip = "92014"

      expect(@name1.widget.getText).to eq("Robertissimo")
      expect(@address1_street_text_widget.widget.getText).to eq("123 Main St")
      expect(@address1_city_text_widget.widget.getText).to eq("Chicago")
      expect(@address1_state_text_widget.widget.getText).to eq("IL")
      expect(@address1_zip_text_widget.widget.getText).to eq("60654")

      expect(@name2.widget.getText).to eq("Bobissimo")
      expect(@address2_street_text_widget.widget.getText).to eq("100 Park Ave")
      expect(@address2_city_text_widget.widget.getText).to eq("San Diego")
      expect(@address2_state_text_widget.widget.getText).to eq("CA")
      expect(@address2_zip_text_widget.widget.getText).to eq("92014")

      person.names[1] = person.names[0]
      person.addresses[1] = person.addresses[0]

      expect(@name2.widget.getText).to eq("Robertissimo")
      expect(@address2_street_text_widget.widget.getText).to eq("123 Main St")
      expect(@address2_city_text_widget.widget.getText).to eq("Chicago")
      expect(@address2_state_text_widget.widget.getText).to eq("IL")
      expect(@address2_zip_text_widget.widget.getText).to eq("60654")

      person.names[1] = nil
      person.addresses[1] = nil

      expect(@name2.widget.getText).to eq("")
      expect(@address2_street_text_widget.widget.getText).to eq("")
      expect(@address2_city_text_widget.widget.getText).to eq("")
      expect(@address2_state_text_widget.widget.getText).to eq("")
      expect(@address2_zip_text_widget.widget.getText).to eq("")

      person.addresses[1] = Address.new

      person.addresses[1].street = "101 Confession St"
      person.addresses[1].city = "Denver"
      person.addresses[1].state = "CO"
      person.addresses[1].zip = "80014"

      expect(@address2_street_text_widget.widget.getText).to eq("101 Confession St")
      expect(@address2_city_text_widget.widget.getText).to eq("Denver")
      expect(@address2_state_text_widget.widget.getText).to eq("CO")
      expect(@address2_zip_text_widget.widget.getText).to eq("80014")

      person.addresses[1].street = "123 Main St"
      person.addresses[1].city = "Chicago"
      person.addresses[1].state = "IL"
      person.addresses[1].zip = "60654"

      expect(@address2_street_text_widget.widget.getText).to eq("123 Main St")
      expect(@address2_city_text_widget.widget.getText).to eq("Chicago")
      expect(@address2_state_text_widget.widget.getText).to eq("IL")
      expect(@address2_zip_text_widget.widget.getText).to eq("60654")
    end
  end
end
