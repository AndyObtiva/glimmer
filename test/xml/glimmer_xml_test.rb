################################################################################
# Copyright (c) 2008 Annas Al Maleh.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#    Annas Al Maleh - initial API and implementation
################################################################################

require File.dirname(__FILE__) + "/../helper"
require File.dirname(__FILE__) + "/../../lib/parent"

class GlimmerXmlTest < Test::Unit::TestCase
  include Glimmer

  def setup
    dsl :xml
  end

  def test_single_html_tag
    @target = html

    assert_not_nil @target
    assert_equal "<html/>", @target.to_xml
  end

  def test_single_document_tag_upper_case
    @target = tag(:_name => "DOCUMENT")

    assert_not_nil @target
    assert_equal "<DOCUMENT/>", @target.to_xml
  end

  def test_open_and_closed_html_tag
    @target = html {}

    assert_not_nil @target
    assert_equal "<html></html>", @target.to_xml
  end

  def test_open_and_closed_html_tag_with_contents
    @target = html { "This is an HTML Document" }

    assert_not_nil @target
    assert_equal "<html>This is an HTML Document</html>", @target.to_xml
  end

  def test_open_and_closed_html_tag_with_contents
    @target = html { "This is an HTML Document" }

    assert_not_nil @target
    assert_equal "<html>This is an HTML Document</html>", @target.to_xml
  end

  def test_open_and_closed_html_tag_with_attributes
    @target = html(:id => "thesis", :class => "document") {
    }

    assert_not_nil @target
    assert_equal '<html id="thesis" class="document"></html>', @target.to_xml
  end

  def test_open_and_closed_html_tag_with_attributes_and_nested_body_with_attributes
    @target = html(:id => "thesis", :class => "document") {
      body(:id => "main") {
      }
    }

    assert_not_nil @target
    assert_equal '<html id="thesis" class="document"><body id="main"></body></html>', @target.to_xml
  end

  def test_tag_with_contents_before_and_after_nested_tag
    @target = html(:id => "thesis", :class => "document") {
      text "Before body"
      body(:id => "main") {
      }
      text "When a string is the last part of the tag contents, text prefix is optional"
    }

    assert_not_nil @target
    assert_equal '<html id="thesis" class="document">Before body<body id="main"></body>When a string is the last part of the tag contents, text prefix is optional</html>', @target.to_xml
  end

  def test_different_name_spaced_tags
    @target = w3c.html(:id => "thesis", :class => "document") {
      document.body(:id => "main") {
      }
    }

    assert_not_nil @target
    assert_equal '<w3c:html id="thesis" class="document"><document:body id="main"></document:body></w3c:html>', @target.to_xml
  end

  def test_different_name_spaced_attributes_and_tags
    @target = w3c.html(w3c.id => "thesis", :class => "document") {
      document.body(document.id => "main") {
      }
    }

    assert_not_nil @target
    assert_equal '<w3c:html w3c:id="thesis" class="document"><document:body document:id="main"></document:body></w3c:html>', @target.to_xml
  end

  def test_name_space_context
    @target = name_space(:w3c) {
      html(:id => "thesis", :class => "document") {
        body(:id => "main") {
        }
      }
    }

    assert_not_nil @target
    assert_equal '<w3c:html id="thesis" class="document"><w3c:body id="main"></w3c:body></w3c:html>', @target.to_xml
  end

  def test_two_name_space_contexts
    @target = name_space(:w3c) {
      html(:id => "thesis", :class => "document") {
        name_space(:document) {
          sectionDivider(:id => "main") {
          }
        }
      }
    }

    assert_not_nil @target
    assert_equal '<w3c:html id="thesis" class="document"><document:sectionDivider id="main"></document:sectionDivider></w3c:html>', @target.to_xml
  end

  def test_two_name_space_contexts_including_contents
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

    assert_not_nil @target
    assert_equal '<w3c:html id="thesis" class="document">before section divider<document:sectionDivider id="main">section divider</document:sectionDivider>after section divider</w3c:html>', @target.to_xml
  end

  def test_mixed_contents_custom_syntax
    @target = html{"before section divider#strong{section divider}after section divider"}

    assert_not_nil @target
    assert_equal '<html>before section divider<strong>section divider</strong>after section divider</html>', @target.to_xml
  end

  #TODO handle special characters such as #, {, }, and .
  #TODO CDATA support
  #TODO encode special characters

  def test_html_alternative_syntax_for_id_and_class_attributes
    @target = html_thesis_document {
      body_main {
        h1__title
      }
    }

    assert_not_nil @target
    assert_equal '<html id="thesis" class="document"><body id="main"><h1 class="title" /></body></html>', @target.to_xml
  end

end


