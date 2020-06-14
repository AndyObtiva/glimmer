require 'spec_helper'

require 'fixtures/glimmer/dsl/swt/dsl'
require 'fixtures/glimmer/dsl/xml/dsl'
require 'fixtures/glimmer/dsl/css/dsl'

module GlimmerSpec
  describe Glimmer::DSL::Engine do
    include Glimmer
 
    it 'mixes multiple DSLs (SWT and XML)' do
      @target = shell {
        browser {
          text html {
            body {
              input(type: 'text', value: 'Hello, World!')
            }
          }
        }
      }
        
      expect(@target.to_s).to eq('SWT shell { SWT Dynamic browser(XML html { XML Dynamic body { XML Dynamic input({:type=>"text", :value=>"Hello, World!"}) } }) }')
    end
 
    it 'disables SWT DSL to build an XML document containing SWT keywords' do
      Glimmer::DSL::Engine.disable_dsl(:swt)
 
      @target = html {
        shell {
          browser
        }
      }
        
      expect(@target.to_s).to eq('XML html { XML Dynamic shell { XML Dynamic browser } }')
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
        
      expect(@target.to_s).to eq('CSS css { CSS Dynamic shell(red)CSS Dynamic html(blue) }')
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
        
      expect(@target.to_s).to eq('SWT shell { SWT Dynamic browser(XML html { XML Dynamic body { XML Dynamic input({:type=>"text", :value=>"Hello, World!"}) } }) }')      
    end
 
    it 'enables specified DSLs only' do
      Glimmer::DSL::Engine.enabled_dsls = [:xml, :css]
      expect(Glimmer::DSL::Engine.disabled_dsls).to eq([:swt])
 
      @target = html {
        shell {
          browser
        }
        style {
          content css {
            body {
              font_size '1.1em'
            }
          }
        }
      }
        
      expect(@target.to_s).to eq('XML html { XML Dynamic shell { XML Dynamic browser }XML Dynamic style(CSS css { CSS Dynamic body(1.1em) }) }')
    end
  end
end
