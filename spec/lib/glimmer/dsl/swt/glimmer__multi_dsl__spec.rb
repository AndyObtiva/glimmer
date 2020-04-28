require "spec_helper"

module GlimmerSpec
  describe 'multi-DSL support' do
    include Glimmer
    it 'mixes multiple DSLs (SWT and XML)' do
      @target = shell {
        @browser = browser {
          text html {
            body {
              input(type: 'text', value: 'Hello, World!')
            }
          }
        }
      }
       
      @browser.on_completed do
        expect(@browser.swt_widget.getText).to eq('<html><body><input type="text" value="Hello, World!"></body></html>')
      end
    end
  end
end
