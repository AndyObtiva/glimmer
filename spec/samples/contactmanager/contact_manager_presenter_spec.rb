require "spec_helper"
require_relative "../../../samples/contactmanager/contact_manager_presenter"

describe ContactManagerPresenter do

  it "tests find_specify_all_fields_for_one_result" do
    contact_manager_presenter = ContactManagerPresenter.new
    contact_manager_presenter.first_name = "Frank"
    contact_manager_presenter.last_name = "Deelio"
    contact_manager_presenter.email = "frank@deelio.com"
    contact_manager_presenter.find
    contacts = contact_manager_presenter.results
    expect(contacts).to_not be_nil
    expect(contacts.size).to eq( 1)
    contact = contacts[0]
    expect(contact.is_a?(Contact)).to be_true
    expect(contact.first_name).to eq( "Frank")
    expect(contact.last_name).to eq( "Deelio")
    expect(contact.email).to eq( "frank@deelio.com")
  end

  it "tests find_specify_one_field_for_two_results" do
    contact_manager_presenter = ContactManagerPresenter.new
    contact_manager_presenter.first_name = "Frank"
    contact_manager_presenter.find
    contacts = contact_manager_presenter.results
    expect(contacts).to_not be_nil
    expect(contacts.size).to eq( 2)
    contact1 = contacts[0]
    contact2 = contacts[1]
    expect(contact1.first_name).to eq( "Frank")
    expect(contact1.last_name).to eq( "Deelio")
    expect(contact1.email).to eq( "frank@deelio.com")
    expect(contact2.first_name).to eq( "franky")
    expect(contact2.last_name).to eq( "miller")
    expect(contact2.email).to eq( "frank@miller.com")
  end

  it "tests find_specify_all_fields_for_no_results" do
    contact_manager_presenter = ContactManagerPresenter.new
    contact_manager_presenter.first_name = "Julia"
    contact_manager_presenter.last_name = "Big"
    contact_manager_presenter.email = "julia@big.com"
    contact_manager_presenter.find
    contacts = contact_manager_presenter.results
    expect(contacts).to_not be_nil
    expect(contacts.size).to eq( 0)
  end

  it "tests find_specify_no_fields_for_all_results" do
    contact_manager_presenter = ContactManagerPresenter.new
    contact_manager_presenter.find
    contacts = contact_manager_presenter.results
    expect(contacts).to_not be_nil
    expect(contacts.size).to eq( 4)
    expect(contacts[0].first_name).to eq( "Anne")
    expect(contacts[1].first_name).to eq( "Beatrice")
    expect(contacts[2].first_name).to eq( "Frank")
    expect(contacts[3].first_name).to eq( "franky")
  end

  it "tests list_all_results" do
    contact_manager_presenter = ContactManagerPresenter.new
    contact_manager_presenter.list
    contacts = contact_manager_presenter.results
    expect(contacts).to_not be_nil
    expect(contacts.size).to eq( 4)
    expect(contacts[0].first_name).to eq( "Anne")
    expect(contacts[1].first_name).to eq( "Beatrice")
    expect(contacts[2].first_name).to eq( "Frank")
    expect(contacts[3].first_name).to eq( "franky")
  end

  it "tests initial_results" do
    contact_manager_presenter = ContactManagerPresenter.new
    contacts = contact_manager_presenter.results
    expect(contacts).to_not be_nil
    expect(contacts.size).to eq( 0)
  end

end