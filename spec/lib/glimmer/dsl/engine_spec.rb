require 'spec_helper'

require 'tempfile'

# test top-level binding inclusion of Glimmer

include Glimmer

GLIMMER_TOP_LEVEL_TARGET = shell {
  browser {
    text html {
      body {
        input(type: 'text', value: 'Hello, World!')
      }
    }
  }
}

module GlimmerSpec
  describe Glimmer::DSL::Engine do
    include Glimmer
    
    context 'No DSLs' do
      before do
        @dynamic_expression_chains_of_responsibility = described_class.dynamic_expression_chains_of_responsibility
        described_class.dynamic_expression_chains_of_responsibility = {}
        @static_expressions = described_class.static_expressions
        described_class.static_expressions = {}
        @stdout_original = $stdout
      end

      after do
        $stdout = @stdout_original
        described_class.static_expressions = @static_expressions
        described_class.dynamic_expression_chains_of_responsibility = @dynamic_expression_chains_of_responsibility
      end
      
      it 'displays an error message without crashing' do
        $stdout = StringIO.new
        Glimmer::Config.reset_logger! # initializes logger with new stdout
        shell # keyword in non-configured SWT DSL
        expect($stdout.string).to include("Glimmer has no DSLs configured. Add glimmer-dsl-swt gem or visit https://github.com/AndyObtiva/glimmer#multi-dsl-support for more details.\n")
      end
    end
    
    context 'DSLs defined' do
      it 'mixes multiple DSLs (SWT and XML)' do
        @target = shell {
          expect {body}.to raise_error(NameError) # ensure swt_dynamic_expression cannot handle this here
        
          browser {
            text html {
              body {
                input(type: 'text', value: 'Hello, World!')
              }
            }
          }
        }
          
        expect(@target.to_s).to eq('SWT shell { SWT Dynamic browser(XML html { XML Dynamic body { XML Dynamic input({:type=>"text", :value=>"Hello, World!"}) } }) }')
        expect(GLIMMER_TOP_LEVEL_TARGET.to_s).to eq('SWT shell { SWT Dynamic browser(XML html { XML Dynamic body { XML Dynamic input({:type=>"text", :value=>"Hello, World!"}) } }) }')
      end
      
      it 'standard static expression' do
        @target = shell {
        }
          
        expect(@target.to_s).to eq('SWT shell')
      end
      
      it 'case-insensitive (upcased/capitalized/downcased) static expression' do
        @target = SHELL {
        }
          
        expect(@target.to_s).to eq('SWT SHELL')
        
        @target = Shell {
        }
          
        expect(@target.to_s).to eq('SWT Shell')
        
        @target = shell {
        }
          
        expect(@target.to_s).to eq('SWT shell')
      end
      
      it 'upcased-only static expression' do
        @target = UPCASED_SHELL {
        }
          
        expect(@target.to_s).to eq('SWT UPCASED_SHELL')
        
        @target = Upcased_shell {
        }
          
        expect(@target.to_s).to_not eq('SWT Upcased_shell')
        # It gets handled by the dynamic expression instead
        expect(@target.to_s).to eq('SWT Dynamic Upcased_shell')
        
        @target = upcased_shell {
        }
          
        expect(@target.to_s).to_not eq('SWT upcased_shell')
        # It gets handled by the dynamic expression instead
        expect(@target.to_s).to eq('SWT Dynamic upcased_shell')
      end
      
      it 'capitalized-only static expression' do
        @target = Capitalized_shell {
        }

        expect(@target.to_s).to eq('SWT Capitalized_shell')
        
        @target = CAPITALIZED_SHELL {
        }
          
        expect(@target.to_s).to_not eq('SWT CAPITALIZED_SHELL')
        # It gets handled by the dynamic expression instead
        expect(@target.to_s).to eq('SWT Dynamic CAPITALIZED_SHELL')
        
        @target = capitalized_shell {
        }
          
        expect(@target.to_s).to_not eq('SWT capitalized_shell')
        # It gets handled by the dynamic expression instead
        expect(@target.to_s).to eq('SWT Dynamic capitalized_shell')
      end
      
      it 'supports bind ModelBinding-producing expression' do
        object = Struct.new(:name).new('Sean')
        @target = bind(object, :name)
          
        expect(@target).to be_a(Glimmer::DataBinding::ModelBinding)
        expect(@target.evaluate_property).to eq('Sean')
      end
               
      it 'raises error for static non-top-level keyword used at the top-level' do
        expect {text}.to raise_error
      end
      
      it 'raises error for a static keyword that cannot interpret args (e.g. text does not accept numeric)' do
        @target = shell {
          expect {text(123)}.to raise_error
        }
      end
      
      it 'processes a static keyword that cannot interpret args (e.g. text does not accept numeric) with the available dynamic expressions' do
        @target = shell {
          @spinner = spinner
        }
        
        expect(@spinner).to be_a(Glimmer::DSL::Element)
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
    
    context 'around hook' do
      it 'executes code around interpret and add_content' do
        Glimmer::DSL::Engine.enabled_dsls = [:swt]
        @target = shell {
          composite_with_around_stack {
            browser_with_around_stack {
              text 'browser title'
            }
          }
        }
        
        expect(@target.to_s).to eq('SWT shell { SWT Dynamic composite_with_around_stack(shell,composite_with_around_stack) { SWT Dynamic browser_with_around_stack(shell,composite_with_around_stack,browser_with_around_stack)(browser title) } }')
      end
      
    end
    
  end
  
end
