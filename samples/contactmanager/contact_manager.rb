require_relative "contact_manager_presenter"
require_relative "../../lib/glimmer"

class RWidget
  include_package 'org.eclipse.jface.viewers'
end

class ContactManager
  extend Glimmer

  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.widgets'
  include_package 'org.eclipse.swt.layout'
  include_package 'org.eclipse.jface.viewers'
  
  contact_manager_presenter = ContactManagerPresenter.new
  
  shell {
    text "Contact Manager"
    composite {
      composite {
        layout GridLayout.new(2, false)
        label {text "First &Name: "}
        text {
          text bind(contact_manager_presenter, :first_name)
        }
        label {text "&Last Name: "}
        text {
          text bind(contact_manager_presenter, :last_name)
        }
        label {text "&Email: "}
        text {
          text bind(contact_manager_presenter, :email)
        }
      }
      
      table {
        layout_data GridData.new(:fill.swt_constant, :fill.swt_constant, true, true)
        table_column {
          text "First Name"
          width 80
        }
        table_column {
          text "Last Name"
          width 80
        }
        table_column {
          text "Email"
          width 120
        }
        items bind(contact_manager_presenter, :results), 
              column_properties(:first_name, :last_name, :email)
      }
      composite {
        layout GridLayout.new(2, false)
        button {
          text "&List"
          on_widget_selected {
            contact_manager_presenter.list
          }
        }
        button {
          text "&Find"
          on_widget_selected {
            contact_manager_presenter.find
          }
        }
      }
    }
  }.open
end
