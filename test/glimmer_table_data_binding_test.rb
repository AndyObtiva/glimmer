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

class GlimmerTableDataBindingTest < Test::Unit::TestCase
	include Glimmer

	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.widgets'
	include_package 'org.eclipse.swt.layout'
		
	def teardown
  	@target.display.dispose if @target.display
	end
  
  class Group
    def initialize
      @people = []
    end
    
    attr_accessor :people
  end
	
  class Person 
    attr_accessor :name, :age, :adult
  end

  def test_text_widget_data_binding_string_property
    person1 = Person.new
    person1.name = "Bruce Ting"
    person1.age = 45
    person1.adult = true
    
    person2 = Person.new
    person2.name = "Julia Fang"
    person2.age = 17
    person2.adult = false
    
    group = Group.new
    group.people << person1
    group.people << person2
    
    shell {
      @table = table {
        table_column {
          text "Name"
          width 120
        }
        table_column {
          text "Age"
          width 120
        }
        table_column {
          text "Adult"
          width 120
        }
        items bind(group, :people), column_properties(:name, :age, :adult)
      }
    }
    
    assert_equal 3, @table.widget.getColumnCount
    assert_equal 2, @table.widget.getItems.size
    
    assert_equal "Bruce Ting", @table.widget.getItems[0].getText(0)
    assert_equal "45", @table.widget.getItems[0].getText(1)
    assert_equal "true", @table.widget.getItems[0].getText(2)
    
    assert_equal "Julia Fang", @table.widget.getItems[1].getText(0)
    assert_equal "17", @table.widget.getItems[1].getText(1)
    assert_equal "false", @table.widget.getItems[1].getText(2)
    
    person3 = Person.new
    person3.name = "Andrea Shingle"
    person3.age = 23
    person3.adult = true
    
    group.people << person3
    
    assert_equal 3, @table.widget.getItems.size
    assert_equal "Andrea Shingle", @table.widget.getItems[2].getText(0)
    assert_equal "23", @table.widget.getItems[2].getText(1)
    assert_equal "true", @table.widget.getItems[2].getText(2)
    
    group.people.delete person2
    
    assert_equal 2, @table.widget.getItems.size
    assert_equal "Andrea Shingle", @table.widget.getItems[1].getText(0)
    assert_equal "23", @table.widget.getItems[1].getText(1)
    assert_equal "true", @table.widget.getItems[1].getText(2)
    
    group.people.delete_at(0)
    
    assert_equal 1, @table.widget.getItems.size
    assert_equal "Andrea Shingle", @table.widget.getItems[0].getText(0)
    assert_equal "23", @table.widget.getItems[0].getText(1)
    assert_equal "true", @table.widget.getItems[0].getText(2)
    
    group.people.clear
    
    assert_equal 0, @table.widget.getItems.size
    
    group.people = [person2, person1]
    
    assert_equal 2, @table.widget.getItems.size
    
    assert_equal "Julia Fang", @table.widget.getItems[0].getText(0)
    assert_equal "17", @table.widget.getItems[0].getText(1)
    assert_equal "false", @table.widget.getItems[0].getText(2)
    
    assert_equal "Bruce Ting", @table.widget.getItems[1].getText(0)
    assert_equal "45", @table.widget.getItems[1].getText(1)
    assert_equal "true", @table.widget.getItems[1].getText(2)
    
    group.people += [person1, person2]
    
    assert_equal 4, @table.widget.getItems.size
    
    assert_equal "Bruce Ting", @table.widget.getItems[2].getText(0)
    assert_equal "45", @table.widget.getItems[2].getText(1)
    assert_equal "true", @table.widget.getItems[2].getText(2)
    
    assert_equal "Julia Fang", @table.widget.getItems[3].getText(0)
    assert_equal "17", @table.widget.getItems[3].getText(1)
    assert_equal "false", @table.widget.getItems[3].getText(2)
    
    person1.name = "Bruce Flee"
    
    assert_equal "Bruce Flee", @table.widget.getItems[1].getText(0)
    assert_equal "Bruce Flee", @table.widget.getItems[2].getText(0)
  end
    
end

