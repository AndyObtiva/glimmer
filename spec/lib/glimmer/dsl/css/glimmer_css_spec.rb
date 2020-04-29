require "spec_helper"
  
describe "Glimmer CSS DSL" do
  include Glimmer

  it 'renders empty element selector' do
    @target = css {
      a {
      }
    }
   
    expect(@target).to be_a(Glimmer::CSS::Stylesheet)
    expect(@target.to_css).to eq(<<~CSS
      a {
      }
    CSS
    )
    expect(@target.to_s).to eq(@target.to_css)
  end
   
end
