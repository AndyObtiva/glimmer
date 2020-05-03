class HelloTab
  include Glimmer
  def launch
    shell {
      text "Hello Tab"
      tab_folder {
        tab_item {
          text "English"
          label {
            text "Hello, World!"
          }
        }
        tab_item {
          text "French"
          label {
            text "Bonjour Univers!"
          }
        }
      }
    }.open
  end
end

HelloTab.new.launch
