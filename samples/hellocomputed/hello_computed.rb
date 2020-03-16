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
        layout (
          GridLayout.new(2, true).tap {|layout|
            layout.horizontalSpacing = 20
            layout.verticalSpacing = 10
          }
        )
        label {text "First &Name: "}
        text {
          text bind(@contact, :first_name)
          layoutData GridData.new.tap { |data|
            data.horizontalAlignment = GridData::FILL
            data.grabExcessHorizontalSpace = true
          }
        }
        label {text "&Last Name: "}
        text {
          text bind(@contact, :last_name)
          layoutData GridData.new.tap { |data|
            data.horizontalAlignment = GridData::FILL
            data.grabExcessHorizontalSpace = true
          }
        }
        label {text "&Year of Birth: "}
        text {
          text bind(@contact, :year_of_birth)
          layoutData GridData.new.tap { |data|
            data.horizontalAlignment = GridData::FILL
            data.grabExcessHorizontalSpace = true
          }
        }
        label {text "Name: "}
        label {
          text bind(@contact, :name, computed_by: [:first_name, :last_name])
          layoutData GridData.new.tap { |data|
            data.horizontalAlignment = GridData::FILL
            data.grabExcessHorizontalSpace = true
          }
        }
        label {text "Age: "}
        label {
          text bind(@contact, :age, :fixnum, computed_by: [:year_of_birth])
          layoutData GridData.new.tap { |data|
            data.horizontalAlignment = GridData::FILL
            data.grabExcessHorizontalSpace = true
          }
        }
      }
    }.open
  end
end

HelloComputed.new.launch
