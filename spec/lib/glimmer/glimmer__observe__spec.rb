require "spec_helper"

module Glimmer
  describe "Glimmer Observe" do
    include Glimmer

    before do
      class Person
        attr_accessor :name, :main_address, :addresses
      end

      class Address
        attr_accessor :main_street, :streets

        def initialize
          @main_street = '123 Main St'
          @streets = ['389 Park Ave', '928 Huron Ave']
        end
      end

      dsl :swt
    end

    after do
      Object.send(:remove_const, :Person) if Object.const_defined?(:Person)
    end

    it 'observes/unobserves model property' do
      person = Person.new

      observer_registration = observe(person, :name) do |new_value|
        expect(person.name).to eq('Sean Bugsley')
        @observer_notified = true
      end

      person.name = 'Sean Bugsley'
      expect(@observer_notified).to eq(true)

      observer_registration.unregister
      @observer_notified = false

      person.name = 'Han Jones'
      expect(@observer_notified).to eq(false)
    end

    it 'observes/unobserves model nested property' do
      person = Person.new
      address = Address.new

      observer_registration = observe(person, 'main_address.main_street') do
        expect(person.main_address.main_street).to eq('123 Main St')
        @observer_notified = true
      end

      person.main_address = address
      expect(@observer_notified).to eq(true)

      observer_registration.unregister
      @observer_notified = false

      observer_registration = observe(person, 'main_address.main_street') do
        expect(person.main_address.main_street).to eq('748 another main street')
        @observer_notified = true
      end

      person.main_address.main_street = '748 another main street'
      expect(@observer_notified).to eq(true)

      observer_registration.unregister
      @observer_notified = false

      person.main_address.main_street = '362 yet another main street'
      expect(@observer_notified).to eq(false)
    end

    it 'observes/unobserves model nested indexed property' do
      person = Person.new
      address = Address.new

      observer_registration = observe(person, 'addresses[0].streets[0]') do
        expect(person.addresses[0].streets[0]).to eq('389 Park Ave')
        @observer_notified = true
      end

      person.addresses = [address]
      expect(@observer_notified).to eq(true)

      observer_registration.unregister
      @observer_notified = false

      observer_registration = observe(person, 'addresses[0].streets[0]') do
        expect(person.addresses[0].streets[0]).to eq('38 Owen Blvd')
        @observer_notified = true
      end

      person.addresses[0].streets[0] = '38 Owen Blvd'
      expect(@observer_notified).to eq(true)

      observer_registration.unregister
      @observer_notified = false

      person.addresses[0].streets[0] = '362 yet another blvd'
      expect(@observer_notified).to eq(false)
    end

    it 'observes/unobserves array property' do
      person = Person.new
      address = Address.new

      observer_registration = observe(person, 'addresses') do
        expect(person.addresses.count).to eq(1)
        @observer_notified = true
      end

      person.addresses = [address]
      expect(@observer_notified).to eq(true)

      observer_registration.unregister
      @observer_notified = false

      observer_registration = observe(person, 'addresses') do
        expect(person.addresses.count).to eq(2)
        @observer_notified = true
      end

      person.addresses << address.clone
      expect(@observer_notified).to eq(true)

      observer_registration.unregister
      @observer_notified = false

      person.addresses.clear
      expect(@observer_notified).to eq(false)
    end
  end
end
