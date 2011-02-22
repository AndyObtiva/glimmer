require File.dirname(__FILE__) + "/../lib/swt"

class Person
  attr_accessor :country, :country_options

  def initialize
    self.country_options=["", "Canada", "US", "Mexico"]
    self.country = "Canada"
  end
end

class HelloCombo
  include Glimmer
  def launch
    person = Person.new
    shell {
      composite {
        combo(read_only) {
          selection bind(person, :country)
        }
        button {
          text "Reset"
          on_widget_selected do
            person.country = "Canada"
          end
        }
      }
    }.open
  end
end

HelloCombo.new.launch