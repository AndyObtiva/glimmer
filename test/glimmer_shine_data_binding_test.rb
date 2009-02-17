################################################################################
# Copyright (c) 2008 Annas Al Maleh.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#    Annas Al Maleh - initial API and implementation
################################################################################ 

require File.dirname(__FILE__) + "/test_helper"
require File.dirname(__FILE__) + "/../lib/shine"

class GlimmerDataBindingTest < Test::Unit::TestCase
	include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'
		
	def teardown
  	@target.display.dispose if @target.display
	end
	
  class Person 
    attr_accessor :name, :age, :adult
  end
  
  def test_text_widget_data_binding_string_property_spaceship
    person = Person.new
    person.name = "Bruce Ting"
    
    @target = shell {
      composite {
        @text = text {
        }
      }
    }
    
    [@text, :text] <=> [person, :name]
    
    assert_equal "Bruce Ting", @text.widget.getText
    
    person.name = "Lady Butterfly"
    assert_equal "Lady Butterfly", @text.widget.getText
    
    @text.widget.setText("Allen Cork")
    assert_equal "Allen Cork", person.name
    
    comparison = ["he"] <=> ["he"]
    assert_equal(0, comparison)
  end
  
  def test_multiple_widget_data_bindings_to_different_model_properties_spaceship
    person = Person.new
    person.name = "Nancy"
    person.age = 15
    person.adult = true
    
    @target = shell {
      composite {
        @label = label {}
        @text = text {}
        @check_box = button(SWT::CHECK) {}
      }
    }
    
    [@label,     :text]      <=> [person, :name]
    [@text,      :text]      <=> [person, :age, :fixnum]
    [@check_box, :selection] <=> [person, :adult]
    
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

