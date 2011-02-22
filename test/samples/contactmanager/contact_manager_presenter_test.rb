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

require File.dirname(__FILE__) + "/../../helper"
require File.dirname(__FILE__) + "/../../../samples/contactmanager/contact_manager_presenter"

class ContactManagerPresenterTest < Test::Unit::TestCase

  def test_find_specify_all_fields_for_one_result
    contact_manager_presenter = ContactManagerPresenter.new
    contact_manager_presenter.first_name = "Frank"
    contact_manager_presenter.last_name = "Deelio"
    contact_manager_presenter.email = "frank@deelio.com"
    contact_manager_presenter.find
    contacts = contact_manager_presenter.results
    assert_not_nil contacts
    assert_equal 1, contacts.size
    contact = contacts[0]
    assert contact.is_a?(Contact)
    assert_equal "Frank", contact.first_name
    assert_equal "Deelio", contact.last_name
    assert_equal "frank@deelio.com", contact.email
  end
  
  def test_find_specify_one_field_for_two_results
    contact_manager_presenter = ContactManagerPresenter.new
    contact_manager_presenter.first_name = "Frank"
    contact_manager_presenter.find
    contacts = contact_manager_presenter.results
    assert_not_nil contacts
    assert_equal 2, contacts.size
    contact1 = contacts[0]
    contact2 = contacts[1]
    assert_equal "Frank", contact1.first_name
    assert_equal "Deelio", contact1.last_name
    assert_equal "frank@deelio.com", contact1.email
    assert_equal "franky", contact2.first_name
    assert_equal "miller", contact2.last_name
    assert_equal "frank@miller.com", contact2.email
  end
  
  def test_find_specify_all_fields_for_no_results
    contact_manager_presenter = ContactManagerPresenter.new
    contact_manager_presenter.first_name = "Julia"
    contact_manager_presenter.last_name = "Big"
    contact_manager_presenter.email = "julia@big.com"
    contact_manager_presenter.find
    contacts = contact_manager_presenter.results
    assert_not_nil contacts
    assert_equal 0, contacts.size
  end
  
  def test_initial_results
    contact_manager_presenter = ContactManagerPresenter.new
    contacts = contact_manager_presenter.results
    assert_not_nil contacts
    assert_equal 0, contacts.size
  end
  
end