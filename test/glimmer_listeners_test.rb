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
  
  def test_text_widget_verify_listener
    @target = shell {
      composite {
        @text = text {
          text "Howdy"
          on_verify_text do |verify_event|
            verify_event.doit = false if verify_event.text == "Hello"
          end
        }
      }
    }
    
    @text.widget.setText("Hi")
    assert_equal "Hi", @text.widget.getText
    
    @text.widget.setText("Hello")
    assert_equal "Hi", @text.widget.getText
  end
    
  def test_button_widget_selection_listener
    person = Person.new
    person.name = "Bruce Ting"
    
    @target = shell {
      composite {
        @button = button {
          on_widget_selected do
            person.name = "Bruce Lao"
          end
        }
      }
    }
    assert_equal "Bruce Ting", person.name
    @button.widget.setSelection(true)
    @button.widget.notifyListeners(SWT::Selection, nil)
    assert_equal "Bruce Lao", person.name
  end
    
end

