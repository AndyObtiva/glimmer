require_relative "helper"

class GlimmerDataBindingTest < Test::Unit::TestCase
  include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'
		
  def setup
    dsl :swt
  end

	def teardown
  	@target.display.dispose if @target.display
	end
	
  class Person 
    attr_accessor :name, :age, :adult
  end
  
  def test_text_widget_data_binding_string_property
    person = Person.new
    person.name = "Bruce Ting"
    
    @target = shell {
      composite {
        @text = text {
          text bind(person, :name)
        }
      }
    }
    
    assert_equal "Bruce Ting", @text.widget.getText
    
    person.name = "Lady Butterfly"
    assert_equal "Lady Butterfly", @text.widget.getText
    
    @text.widget.setText("Allen Cork")
    assert_equal "Allen Cork", person.name
  end
    
  def test_text_widget_data_binding_fixnum_property
    person = Person.new
    person.age = 15
    
    @target = shell {
      composite {
        @text = text {
          text bind(person, :age, :fixnum)
        }
      }
    }
    
    assert_equal "15", @text.widget.getText
    
    person.age = 27
    assert_equal "27", @text.widget.getText
    
    @text.widget.setText("30")
    assert_equal 30, person.age
  end
    
  def test_label_widget_data_binding_string_property
    person = Person.new
    person.name = "Bruce Ting"
    
    @target = shell {
      composite {
        @label = label {
          text bind(person, :name)
        }
      }
    }
    
    assert_equal "Bruce Ting", @label.widget.getText
    
    person.name = "Lady Butterfly"
    assert_equal "Lady Butterfly", @label.widget.getText
  end
    
  def test_checkbox_widget_data_binding_boolean_property
    person = Person.new
    person.adult = true
    
    @target = shell {
      composite {
        @check_box = button(:check) {
          selection bind(person, :adult)
        }
      }
    }
    
    assert_equal true, @check_box.widget.getSelection
    
    person.adult = false
    assert_equal false, @check_box.widget.getSelection
    
    @check_box.widget.setSelection(true)
    @check_box.widget.notifyListeners(SWT::Selection, nil)
    assert_equal true, person.adult
  end
    
  def test_radio_widget_data_binding_boolean_property
    person = Person.new
    person.adult = true
    
    @target = shell {
      composite {
        @radio = button(:radio) {
          selection bind(person, :adult)
        }
      }
    }
    
    assert_equal true, @radio.widget.getSelection
    
    person.adult = false
    assert_equal false, @radio.widget.getSelection
    
    @radio.widget.setSelection(true)
    @radio.widget.notifyListeners(SWT::Selection, nil)
    assert_equal true, person.adult
  end
    
  def test_spinner_widget_data_binding_fixnum_property
    person = Person.new
    person.age = 17
    
    @target = shell {
      composite {
        @spinner = spinner {
          selection bind(person, :age)
        }
      }
    }
    
    assert_equal 17, @spinner.widget.getSelection
    
    person.age = 20
    assert_equal 20, @spinner.widget.getSelection
    
    @spinner.widget.setSelection(34)
    @spinner.widget.notifyListeners(SWT::Selection, nil)
    assert_equal 34, person.age
  end
    
  def test_widget_data_binding_enablement
    person = Person.new
    person.adult = true
    
    @target = shell {
      composite {
        @text = text {
          enabled bind(person, :adult)
        }
      }
    }
    
    assert_equal true, @text.widget.isEnabled
    
    person.adult = false
    assert_equal false, @text.widget.isEnabled
  end
    
  def test_multiple_widget_data_binding_enablement_to_same_model_property
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
    
    assert_equal true, @text.widget.isEnabled
    assert_equal true, @text2.widget.isEnabled
    assert_equal true, @text3.widget.isEnabled
    
    person.adult = false
    assert_equal false, @text.widget.isEnabled
    assert_equal false, @text2.widget.isEnabled
    assert_equal false, @text3.widget.isEnabled
  end
    
  def test_multiple_widget_data_bindings_to_different_model_properties
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
    
    assert_equal "Nancy", @label.widget.getText
    assert_equal "15", @text.widget.getText
    assert_equal true, @check_box.widget.getSelection
    
    person.name = "Drew"
    assert_equal "Drew", @label.widget.getText
    
    person.age = 27
    assert_equal "27", @text.widget.getText

    person.adult = false
    assert_equal false, @check_box.widget.getSelection
    
    @text.widget.setText("30")
    assert_equal 30, person.age

    @check_box.widget.setSelection(true)
    @check_box.widget.notifyListeners(SWT::Selection, nil)
    assert_equal true, person.adult
  end
    
end

