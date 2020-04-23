require_relative "contact"

class HelloComputed
  include Glimmer

  def initialize
    @contact = Contact.new(
      first_name: "Barry",
      last_name: "McKibbin",
      year_of_birth: 1985
    )
  end

  def launch
    shell {
      text "Hello Computed"
      composite {
        grid_layout {
          num_columns 2
          make_columns_equal_width true
          horizontal_spacing 20
          vertical_spacing 10
        }
        label {text "First &Name: "}
        text {
          text bind(@contact, :first_name)
          layout_data {
            horizontalAlignment :fill
            grabExcessHorizontalSpace true
          }
        }
        label {text "&Last Name: "}
        text {
          text bind(@contact, :last_name)
          layout_data {
            horizontalAlignment :fill
            grabExcessHorizontalSpace true
          }
        }
        label {text "&Year of Birth: "}
        text {
          text bind(@contact, :year_of_birth)
          layout_data {
            horizontalAlignment :fill
            grabExcessHorizontalSpace true
          }
        }
        label {text "Name: "}
        label {
          text bind(@contact, :name, computed_by: [:first_name, :last_name])
          layout_data {
            horizontalAlignment :fill
            grabExcessHorizontalSpace true
          }
        }
        label {text "Age: "}
        label {
          text bind(@contact, :age, on_write: :to_i, computed_by: [:year_of_birth])
          layout_data {
            horizontalAlignment :fill
            grabExcessHorizontalSpace true
          }
        }
      }
    }.open
  end
end

HelloComputed.new.launch
