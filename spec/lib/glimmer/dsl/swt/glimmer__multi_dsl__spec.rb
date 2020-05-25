require "spec_helper"

module GlimmerSpec
  describe 'multi-DSL support' do
    include Glimmer

    unless OS.linux?
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
       
      expect(@target.to_s).to eq('shell{background:red}html{color:blue}')
    end

    unless OS.linux?
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
  
      it 'enables specified DSLs only' do
        Glimmer::DSL::Engine.enabled_dsls = [:xml, :css]
        expect(Glimmer::DSL::Engine.disabled_dsls).to eq([:swt])
  
        @target = html {
          shell {
            browser
          }
          style {
            css {
              body {
                font_size '1.1em'
              }
            }
          }
        }
         
        expect(@target.to_s).to eq('<html><shell><browser/></shell><style>body{font-size:1.1em}</style></html>')
      end
    end
  end
end
