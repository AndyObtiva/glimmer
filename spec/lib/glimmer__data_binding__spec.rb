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

end
