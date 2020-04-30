require "spec_helper"
  
describe "Glimmer Xml" do
  include Glimmer

  it "tests single html tag" do
    @target = html
   
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq("<html/>")
  end
   
  it "tests single document tag upper case" do
    @target = tag(:_name => "DOCUMENT")
    
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq("<DOCUMENT/>")
  end
  
  it "tests open and closed html tag" do
    @target = html {}
   
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq("<html></html>")
  end
   
  it "tests open and closed html tag with contents" do
    @target = html { "This is an HTML Document" }
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq("<html>This is an HTML Document</html>")
  end
  
  it "tests open and closed html tag with attributes" do
    @target = html(:id => "thesis", :class => "document") {
    }
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq('<html id="thesis" class="document"></html>')
  end
  
  it "tests open and closed html tag with attributes and nested body with attributes" do
    @target = html(:id => "thesis", :class => "document") {
      body(:id => "main") {
      }
    }
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq('<html id="thesis" class="document"><body id="main"></body></html>')
  end
  
  it "renders html tag with nested body and video with attributes, including non-value attributes (e.g. loop)" do
    @target = html {
      body {
        video(:loop, :controls, src: "http://videos.org/1.mp4")
      }
    }
  
    expect(@target.to_xml).to eq('<html><body><video src="http://videos.org/1.mp4" loop controls /></body></html>')
  end

  it 'renders meta tag' do
    @target = html {
      head {
        meta(name: "viewport", content: "width=device-width, initial-scale=2.0")
      }
    }
  
    expect(@target.to_xml).to eq('<html><head><meta name="viewport" content="width=device-width, initial-scale=2.0" /></head></html>')
  end
  
  it "tests tag with contents before and after nested tag" do
    @target = html(:id => "thesis", :class => "document") {
      text "Before body"
      body(:id => "main") {
      }
      text "When a string is the last part of the tag contents, text prefix is optional"
    }
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq('<html id="thesis" class="document">Before body<body id="main"></body>When a string is the last part of the tag contents, text prefix is optional</html>')
  end
  
  it "tests different name spaced tags" do
    @target = html(:id => "thesis", :class => "document") {
      document.body(:id => "main") {
      }
    }
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq('<html id="thesis" class="document"><document:body id="main"></document:body></html>')
  end
  
  it "tests different name spaced attributes and tags" do
    @target = html(:id => "thesis", :class => "document") {
      document.body(document.id => "main") {
      }
    }
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq('<html id="thesis" class="document"><document:body document:id="main"></document:body></html>')
  end
  
  it "tests name space context" do
    @target = name_space(:w3c) {
      html(:id => "thesis", :class => "document") {
        body(:id => "main") {
        }
      }
    }
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq('<w3c:html id="thesis" class="document"><w3c:body id="main"></w3c:body></w3c:html>')
  end
  
  it "tests two name space contexts" do
    @target = name_space(:w3c) {
      html(:id => "thesis", :class => "document") {
        name_space(:document) {
          sectionDivider(:id => "main") {
          }
        }
      }
    }
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq('<w3c:html id="thesis" class="document"><document:sectionDivider id="main"></document:sectionDivider></w3c:html>')
  end
  
  it "tests two name space contexts including contents" do
    @target = name_space(:w3c) {
      html(:id => "thesis", :class => "document") {
        text "before section divider"
        name_space(:document) {
          sectionDivider(:id => "main") {
            "section divider"
          }
        }
        text "after section divider"
      }
    }
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq('<w3c:html id="thesis" class="document">before section divider<document:sectionDivider id="main">section divider</document:sectionDivider>after section divider</w3c:html>')
  end
  
  it "tests mixed contents custom syntax" do
    @target = html{"before section divider#strong{section divider}after section divider"}
  
    expect(@target).to_not be_nil
    expect(@target.to_xml).to eq('<html>before section divider<strong>section divider</strong>after section divider</html>')
  end
  
##  TODO handle special characters such as #, {, }, and .
##  TODO CDATA support
##  TODO encode special characters

end
