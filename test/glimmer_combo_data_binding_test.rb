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

require "test/unit"
require File.dirname(__FILE__) + "/../src/swt"

class GlimmerComboDataBindingTest < Test::Unit::TestCase
	include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'
		
	def teardown
  	@target.display.dispose if @target.display
	end
  
  class Person 
    attr_accessor :country, :country_options
    
    def initialize
      self.country_options=["", "Canada", "US", "Mexico"]
    end
  end

  def test_data_binding_selection_property
    person = Person.new
    
    @target = shell {
      @combo = combo {
        selection bind(person, :country)
      }
    }
    
    assert_equal 4, @combo.widget.item_count
    assert_equal 0, @combo.widget.selection_index
    assert_equal "", @combo.widget.text

    person.country_options << "France"
    
    assert_equal 5, @combo.widget.item_count
    
    person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]
    
    assert_equal 6, @combo.widget.item_count
    
    person.country_options << "Italy"
    person.country_options << "Germany"
    person.country_options << "Australia"
    
    assert_equal 9, @combo.widget.item_count
    
    assert_equal 0, @combo.widget.selection_index
    assert_equal "", @combo.widget.text
    
    person.country = "Canada"
    
    assert_equal 1, @combo.widget.selection_index
    assert_equal "Canada", @combo.widget.text

    person.country = "Russia"
    
    assert_equal 4, @combo.widget.selection_index
    assert_equal "Russia", @combo.widget.text

    person.country = ""
    
    assert_equal 0, @combo.widget.selection_index
    assert_equal "", @combo.widget.text

    person.country = "Japan"
    
    assert_equal -1, @combo.widget.selection_index
    assert_equal "Japan", @combo.widget.text
  end
    
  def test_read_only_widget_data_binding_selection_property
    person = Person.new
    person.country = "Canada" 
    
    @target = shell {
      @combo = combo(read_only) {
        selection bind(person, :country)
      }
    }
    
    assert_equal 4, @combo.widget.item_count
    assert_equal 1, @combo.widget.selection_index
    assert_equal "Canada", @combo.widget.text

    person.country_options << "France"
    
    assert_equal 5, @combo.widget.item_count
    
    person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]
    
    assert_equal 6, @combo.widget.item_count
    
    person.country_options << "Italy"
    person.country_options << "Germany"
    person.country_options << "Australia"
    
    assert_equal 9, @combo.widget.item_count
    
    assert_equal -1, @combo.widget.selection_index
    assert_equal "", @combo.widget.text
    
    person.country = "Canada"
    
    assert_equal 1, @combo.widget.selection_index
    assert_equal "Canada", @combo.widget.text

    person.country = "Russia"
    
    assert_equal 4, @combo.widget.selection_index
    assert_equal "Russia", @combo.widget.text

    person.country = ""
    
    assert_equal 0, @combo.widget.selection_index
    assert_equal "", @combo.widget.text

    person.country = "Japan"
    
    assert_equal 0, @combo.widget.selection_index
    assert_equal "", @combo.widget.text
  end
    
end

