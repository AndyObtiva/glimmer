require File.dirname(__FILE__) + "/../lib/glimmer"

class HelloTab
  include Glimmer
  def launch
    shell {
      text "SWT"
      tab_folder {
        tab_item {
          text "Tab 1"
          label {
            text "Hello World!"
          }
        }
        tab_item {
          text "Tab 2"
          label {
            text "Bonjour Univers!"
          }
        }
      }
    }.open
  end
end

HelloTab.new.launch