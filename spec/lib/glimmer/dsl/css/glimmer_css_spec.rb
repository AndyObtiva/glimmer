require "spec_helper"
  
describe "Glimmer CSS DSL" do
  include Glimmer

  it 'renders empty element selector' do
    @target = css {
      a {
      }
    }
   
    expect(@target).to be_a(Glimmer::CSS::StyleSheet)
    expect(@target.to_css).to eq('a{}')
    expect(@target.to_s).to eq(@target.to_css)
  end
   
  it 'renders element selector with one property' do
    @target = css {
      a {
        background :red
      }
    }
   
    expect(@target.to_css).to eq('a{background:red}')
  end
   
  it 'renders element selector with two properties' do
    @target = css {
      a {
        background :red
        text_align :center
      }
    }
   
    expect(@target.to_css).to eq('a{background:red;text-align:center}')
  end
   
  it 'renders two element selectors with two properties each' do
    @target = css {
      h1 {
        font_size '2em'
        font_family '"Times New Roman", Times, serif'
      }
      a {
        background :red
        text_align :center
      }
    }
   
    expect(@target.to_css).to eq('h1{font-size:2em;font-family:"Times New Roman", Times, serif}a{background:red;text-align:center}')
  end
   
  it 'renders two custom selectors with two properties each' do
    @target = css {
      s('body#app h1#title') {
        font_size '2em'
        font_family '"Times New Roman", Times, serif'
      }
      s('section#menu > a#home') {
        background :red
        text_align :center
      }
    }
   
    expect(@target.to_css).to eq('body#app h1#title{font-size:2em;font-family:"Times New Roman", Times, serif}section#menu > a#home{background:red;text-align:center}')
  end
   
  it 'renders two custom selectors with two custom properties each' do
    @target = css {
      s('body#app h1#title') {
        pv 'font-size', '2em'
        pv 'font-family', '"Times New Roman", Times, serif'
      }
      s('section#menu > a#home') {
        pv 'background', 'red'
        pv 'text_align', 'center'
      }
    }
   
    expect(@target.to_css).to eq('body#app h1#title{font-size:2em;font-family:"Times New Roman", Times, serif}section#menu > a#home{background:red;text-align:center}')
  end
   
end
