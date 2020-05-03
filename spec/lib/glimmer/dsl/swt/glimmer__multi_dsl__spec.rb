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

    it 'disables SWT DSL to build an XML document containing SWT keywords' do
      Glimmer::DSL::Engine.disable_dsl(:swt)

      @target = html {
        shell {
          browser
        }
      }
       
      expect(@target.to_s).to eq('<html><shell><browser/></shell></html>')
    end

    it 'disables SWT and XML DSLs to build a CSS style sheet containing SWT and XML keywords' do
      Glimmer::DSL::Engine.disable_dsl(:swt)
      Glimmer::DSL::Engine.disable_dsl(:xml)

      @target = css {
        shell {
          background :red
        }
        html {
          color :blue
        }
      }
       
      expect(@target.to_s).to eq(<<~CSS
        shell {
          background: red;
        }

        html {
          color: blue;
        }
      CSS
      )
    end

    it 'enables disabled DSLs' do
      Glimmer::DSL::Engine.disable_dsl(:swt)
      Glimmer::DSL::Engine.disable_dsl(:xml)
      Glimmer::DSL::Engine.disable_dsl(:css)
      Glimmer::DSL::Engine.enable_dsl(:swt)
      Glimmer::DSL::Engine.enable_dsl(:xml)
      Glimmer::DSL::Engine.enable_dsl(:css)

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
