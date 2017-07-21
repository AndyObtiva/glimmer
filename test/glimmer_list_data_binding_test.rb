require_relative "helper"

class GlimmerListDataBindingTest < Test::Unit::TestCase
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

  def test_single_selection_property
    person = Person.new
    
    @target = shell {
      @list = list {
        selection bind(person, :country)
      }
    }
    
    assert_equal 4, @list.widget.item_count
    assert_equal -1, @list.widget.selection_index
    assert_equal [], @list.widget.selection.to_a

    @list.widget.select(1)
    @list.widget.notifyListeners(SWT::Selection, nil)
    assert_equal "Canada", person.country

    person.country_options << "France"
    
    assert_equal 5, @list.widget.item_count
    
    person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]
    
    assert_equal 6, @list.widget.item_count
    
    person.country_options << "Italy"
    person.country_options << "Germany"
    person.country_options << "Australia"
    
    assert_equal 9, @list.widget.item_count
    
    person.country = "Canada"
    
    assert_equal 1, @list.widget.selection_index
    assert_equal ["Canada"], @list.widget.selection.to_a

    person.country = "Russia"
    
    assert_equal 4, @list.widget.selection_index
    assert_equal ["Russia"], @list.widget.selection.to_a

    person.country = ""
    
    assert_equal 0, @list.widget.selection_index
    assert_equal [""], @list.widget.selection.to_a

    person.country = "Japan"
    
    assert_equal 0, @list.widget.selection_index
    assert_equal [""], @list.widget.selection.to_a
    
    @list.widget.select(2)
    @list.widget.notifyListeners(SWT::Selection, nil)
    assert_equal "US", person.country
  end
    
  def test_single_selection_property_with_model_preinitialized
    person = Person.new
    person.country = "Canada" 
    
    @target = shell {
      @list = list {
        selection bind(person, :country)
      }
    }
    
    assert_equal 4, @list.widget.item_count
    assert_equal 1, @list.widget.selection_index
    assert_equal ["Canada"], @list.widget.selection.to_a

    @list.widget.select(2)
    @list.widget.notifyListeners(SWT::Selection, nil)
    assert_equal "US", person.country

    person.country_options << "France"
    
    assert_equal 5, @list.widget.item_count
    
    person.country_options=["", "Canada", "US", "Mexico", "Russia", "France"]
    
    assert_equal 6, @list.widget.item_count
    
    person.country_options << "Italy"
    person.country_options << "Germany"
    person.country_options << "Australia"
    
    assert_equal 9, @list.widget.item_count
    
    person.country = "Canada"
    
    assert_equal 1, @list.widget.selection_index
    assert_equal ["Canada"], @list.widget.selection.to_a

    person.country = "Russia"
    
    assert_equal 4, @list.widget.selection_index
    assert_equal ["Russia"], @list.widget.selection.to_a

    person.country = ""
    
    assert_equal 0, @list.widget.selection_index
    assert_equal [""], @list.widget.selection.to_a

    person.country = "Japan"
    
    assert_equal 0, @list.widget.selection_index
    assert_equal [""], @list.widget.selection.to_a
  end
  
  def test_multi_selection_property
    person = Person.new
    
    @target = shell {
      @list = list(:multi) {
        selection bind(person, :provinces)
      }
    }
    
    assert_equal 0, @list.widget.selection_count.to_i
    assert_equal [], @list.widget.selection.to_a

    @list.widget.select(1)
    @list.widget.notifyListeners(SWT::Selection, nil)
    assert_equal ["Quebec"], person.provinces

    @list.widget.select(2)
    @list.widget.notifyListeners(SWT::Selection, nil)
    assert_equal ["Quebec", "Ontario"], person.provinces

    person.provinces=["Ontario", "Manitoba", "Alberta"]
    
    assert_equal 3, @list.widget.selection_count.to_i
    assert_equal [2, 3, 5], @list.widget.selection_indices.to_a
    assert_equal ["Ontario", "Manitoba", "Alberta"], @list.widget.selection.to_a
    
    person.provinces << "Quebec"
    person.provinces << "Saskatchewan"
    person.provinces << "British Columbia"
    
    assert_equal 6, @list.widget.selection_count.to_i
    assert_equal [1, 2, 3, 4, 5, 6], @list.widget.selection_indices.to_a
    assert_equal ["Quebec", "Ontario", "Manitoba", "Saskatchewan", "Alberta", "British Columbia"], @list.widget.selection.to_a
   end

  def test_multi_selection_property_with_model_preinitialized
    person = Person.new
    person.provinces = []
    
    @target = shell {
      @list = list(:multi) {
        selection bind(person, :provinces)
      }
    }
    
    assert_equal 0, @list.widget.selection_count.to_i
    assert_equal [], @list.widget.selection.to_a

    @list.widget.select(1)
    @list.widget.notifyListeners(SWT::Selection, nil)
    assert_equal ["Quebec"], person.provinces

    @list.widget.select(2)
    @list.widget.notifyListeners(SWT::Selection, nil)
    assert_equal ["Quebec", "Ontario"], person.provinces

    person.provinces=["Ontario", "Manitoba", "Alberta"]
    
    assert_equal 3, @list.widget.selection_count.to_i
    assert_equal [2, 3, 5], @list.widget.selection_indices.to_a
    assert_equal ["Ontario", "Manitoba", "Alberta"], @list.widget.selection.to_a
    
    person.provinces << "Quebec"
    person.provinces << "Saskatchewan"
    person.provinces << "British Columbia"
    
    assert_equal 6, @list.widget.selection_count.to_i
    assert_equal [1, 2, 3, 4, 5, 6], @list.widget.selection_indices.to_a
    assert_equal ["Quebec", "Ontario", "Manitoba", "Saskatchewan", "Alberta", "British Columbia"], @list.widget.selection.to_a
   end
end

