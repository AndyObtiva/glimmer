require_relative "contact_manager_presenter"

class ContactManager
  include Glimmer

  def initialize
    @contact_manager_presenter = ContactManagerPresenter.new
    @contact_manager_presenter.list
  end

  def launch
    shell {
      text "Contact Manager"
      composite {
        composite {
          grid_layout 2, false
          label {text "First &Name: "}
          text {
            text bind(@contact_manager_presenter, :first_name)
            on_key_pressed {|key_event|
              @contact_manager_presenter.find if key_event.keyCode == Glimmer::SWT::SWTProxy[:cr]
            }
          }
          label {text "&Last Name: "}
          text {
            text bind(@contact_manager_presenter, :last_name)
            on_key_pressed {|key_event|
              @contact_manager_presenter.find if key_event.keyCode == Glimmer::SWT::SWTProxy[:cr]
            }
          }
          label {text "&Email: "}
          text {
            text bind(@contact_manager_presenter, :email)
            on_key_pressed {|key_event|
              @contact_manager_presenter.find if key_event.keyCode == Glimmer::SWT::SWTProxy[:cr]
            }
          }
          composite {
            grid_layout 2, false
            button {
              text "&Find"
              on_widget_selected {
                @contact_manager_presenter.find
              }
            }
            button {
              text "&List All"
              on_widget_selected {
                @contact_manager_presenter.list
              }
            }
          }
        }

        table {
          layout_data {
            horizontal_alignment :fill
            vertical_alignment :fill
            grab_excess_horizontal_space true
            grab_excess_vertical_space true
            height_hint 200
          }
          table_column {
            text "First Name"
            width 80
            on_widget_selected {
              @contact_manager_presenter.toggle_sort(:first_name)
            }
          }
          table_column {
            text "Last Name"
            width 80
            on_widget_selected {
              @contact_manager_presenter.toggle_sort(:last_name)
            }
          }
          table_column {
            text "Email"
            width 200
            on_widget_selected {
              @contact_manager_presenter.toggle_sort(:email)
            }
          }
          items bind(@contact_manager_presenter, :results),
          column_properties(:first_name, :last_name, :email)
        }
      }
    }.open
  end
end

ContactManager.new.launch
