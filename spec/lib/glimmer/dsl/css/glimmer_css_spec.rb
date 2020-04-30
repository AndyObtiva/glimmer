require "spec_helper"
  
describe "Glimmer CSS DSL" do
  include Glimmer

  it 'renders empty element selector' do
    @target = css {
      a {
      }
    }
   
    expect(@target).to be_a(Glimmer::CSS::StyleSheet)
    expect(@target.to_css).to eq(<<~CSS
      a {
      }
    CSS
    )
    expect(@target.to_s).to eq(@target.to_css)
  end
   
  it 'renders element selector with one property' do
    @target = css {
      a {
        background :red
      }
    }
   
    expect(@target.to_css).to eq(<<~CSS
      a {
        background: red;
      }
    CSS
    )
  end
   
  it 'renders element selector with two properties' do
    @target = css {
      a {
        background :red
        text_align :center
      }
    }
   
    expect(@target.to_css).to eq(<<~CSS
      a {
        background: red;
        text-align: center;
      }
    CSS
    )
  end
   
end
