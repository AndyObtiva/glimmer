require_relative "contact_manager_presenter"

class ContactManager
  include Glimmer

  def initialize
    @contact_manager_presenter = ContactManagerPresenter.new
  end

  def launch
    shell {
      text "Contact Manager"
      composite {
        composite {
          layout GridLayout.new(2, false)
          label {text "First &Name: "}
          text {
            text bind(@contact_manager_presenter, :first_name)
          }
          label {text "&Last Name: "}
          text {
            text bind(@contact_manager_presenter, :last_name)
          }
          label {text "&Email: "}
          text {
            text bind(@contact_manager_presenter, :email)
          }
        }

        table {
          layout_data GridData.new(GSWT[:fill], GSWT[:fill], true, true)
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
          items bind(@contact_manager_presenter, :results),
          column_properties(:first_name, :last_name, :email)
        }
        composite {
          layout GridLayout.new(2, false)
          button {
            text "&List"
            on_widget_selected {
              @contact_manager_presenter.list
            }
          }
          button {
            text "&Find"
            on_widget_selected {
              @contact_manager_presenter.find
            }
          }
        }
      }
    }.open
  end
end

ContactManager.new.launch
