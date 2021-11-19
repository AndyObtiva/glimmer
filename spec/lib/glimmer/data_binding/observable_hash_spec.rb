require 'spec_helper'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_hash'

describe Glimmer::DataBinding::ObservableHash do
  context 'hash' do
    it 'adds observer based on key' do
      task = {}
      @observer_called = nil
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      observer.observe(task, :address)
      task[:other] = 'Something'
      expect(@observer_called).to be_nil
      task[:name] = 'Sean'
      expect(@observer_called).to eq('Sean')
      task[:address] = '123 Main St'
      expect(@observer_called).to eq('123 Main St')
    end
    
    it 'adds observer to all keys' do
      task = {}
      @key_called = nil
      @observer_called = nil
      @called = 0
      
      o = Glimmer::DataBinding::Observer.proc do |new_value, key|
        @called += 1
        @key_called = key if key
        @observer_called = new_value
      end
      o.observe(task)
      o.observe(task, :address)
      
      task[:other] = 'Something'
      expect(@key_called).to eq(:other)
      expect(@observer_called).to eq('Something')
      expect(@called).to eq(1)
      
      task[:name] = 'Sean'
      expect(@key_called).to eq(:name)
      expect(@observer_called).to eq('Sean')
      expect(@called).to eq(2)
      
      task[:address] = '123 Main St'
      expect(@key_called).to eq(:address)
      expect(@observer_called).to eq('123 Main St')
      expect(@called).to eq(3)
    end
    
    it 'adds observer to Array key value' do
      task = {}
      task[:name] = 'Sean'
      task[:subtasks] = ['subtask1', 'subtask2']
      @observer_called = nil
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(task, :subtasks)
      task[:subtasks] << 'subtask3'
      expect(@observer_called).to eq(['subtask1', 'subtask2', 'subtask3'])
    end
    
    it 'adds observer to Array of Arrays key value recursively' do
      task = {}
      task[:name] = 'Sean'
      task[:subtasks] = [[['subtask1', 'subtask2']]]
      @observer_called = nil
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      
      observer.observe(task, :subtasks)
      task[:subtasks][0][0] << 'subtask3'
      expect(@observer_called).to be_nil

      observer.unobserve(task, :subtasks)
      
      observer.observe(task, :subtasks, recursive: true)
      task[:subtasks][0][0] << 'subtask4'
      expect(@observer_called).to eq([[["subtask1", "subtask2", "subtask3", "subtask4"]]])
    end
    
    it 'removes observer' do
      task = {}
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      observer.unobserve(task, :name)
      task[:name] = 'Sean'
      expect(@observer_called).to be_nil
    end
    
    it 'removes observers for a key' do
      task = {}
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      task.remove_observers(:name)
      task[:name] = 'Sean'
      expect(@observer_called).to be_nil
    end
    
    it 'removes all observers for all keys' do
      task = {}
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      observer.observe(task, :subtasks)
      task.remove_all_observers
      task[:name] = 'Sean'
      task[:subtasks] = ['subtask1', 'subtask2']
      expect(@observer_called).to be_nil
    end
    
    it 'checks if object has observer for any key' do
      task = {}
      @observer_called = nil
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      expect(task.has_observer_for_any_key?(observer)).to eq(true)
      observer.unobserve(task, :name)
      expect(task.has_observer_for_any_key?(observer)).to eq(false)
    end
  end
  
  describe 'hash mutation method' do
    it 'notifies observers when Hash#delete is called and changes key value (i.e. was not nil before)' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.delete(:name)
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = 'John'
      hash.add_observer(observer) # observe all keys

      hash.delete(:name)
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
    end
    
    it 'does not notify observers when Hash#delete is called and previous key value was nil' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: nil}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.delete(:name)
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = nil
      hash.add_observer(observer) # observe all keys

      hash.delete(:name)
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#delete_if is called and changes key value (i.e. was not nil before)' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.delete_if { |k,v| k == :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = 'John'
      hash.add_observer(observer) # observe all keys

      hash.delete_if { |k,v| k == :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
    end
    
    it 'does not notify observers when Hash#delete_if is called and previous key value was nil' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: nil}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.delete_if { |k,v| k == :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = nil
      hash.add_observer(observer) # observe all keys

      hash.delete_if { |k,v| k == :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#select! is called and changes key value (i.e. was not nil before)' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John', address: '123 Main St, St Antonio, Texas, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.select! { |k,v| k != :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = 'John'
      hash.add_observer(observer) # observe all keys

      hash.select! { |k,v| k != :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
    end
    
    it 'does not notify observers when Hash#select! is called and previous key value was nil' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: nil, address: '123 Main St, St Antonio, Texas, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.select! { |k,v| k != :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = nil
      hash.add_observer(observer) # observe all keys

      hash.select! { |k,v| k != :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#filter! is called and changes key value (i.e. was not nil before)' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John', address: '123 Main St, St Antonio, Texas, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.filter! { |k,v| k != :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = 'John'
      hash.add_observer(observer) # observe all keys

      hash.filter! { |k,v| k != :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
    end
    
    it 'does not notify observers when Hash#filter! is called and previous key value was nil' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: nil, address: '123 Main St, St Antonio, Texas, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.filter! { |k,v| k != :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = nil
      hash.add_observer(observer) # observe all keys

      hash.filter! { |k,v| k != :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#keep_if is called and changes key value (i.e. was not nil before)' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John', address: '123 Main St, St Antonio, Texas, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.keep_if { |k,v| k != :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = 'John'
      hash.add_observer(observer) # observe all keys

      hash.keep_if { |k,v| k != :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
    end
    
    it 'does not notify observers when Hash#keep_if is called and previous key value was nil' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: nil, address: '123 Main St, St Antonio, Texas, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.keep_if { |k,v| k != :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = nil
      hash.add_observer(observer) # observe all keys

      hash.keep_if { |k,v| k != :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#reject! is called and changes key value (i.e. was not nil before)' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John', address: '123 Main St, St Antonio, Texas, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.reject! { |k,v| k == :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = 'John'
      hash.add_observer(observer) # observe all keys

      hash.reject! { |k,v| k == :name }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
    end
    
    it 'does not notify observers when Hash#reject! is called and previous key value was nil' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: nil, address: '123 Main St, St Antonio, Texas, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.reject! { |k,v| k == :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = nil
      hash.add_observer(observer) # observe all keys

      hash.reject! { |k,v| k == :name }
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#shift is called and changes key value (i.e. was not nil before)' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John', address: '123 Main St, St Antonio, Texas, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)
      hash.add_observer(observer, :address)

      hash.shift
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash.remove_observer(observer, :address)
      hash.add_observer(observer) # observe all keys

      hash.shift
      expect(@fired).to eq(true)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(:address)
    end
    
    it 'does not notify observers when Hash#shift is called and previous key value was nil' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: nil, address: nil}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)
      hash.add_observer(observer, :address)

      hash.shift
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash.remove_observer(observer, :address)
      hash.add_observer(observer) # observe all keys

      hash.shift
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#merge! is called and changes key value' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.merge!(name: 'John')
      expect(@fired).to eq(true)
      expect(@changed_value).to eq('John')
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash = {name: 'John'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.merge!(name: 'Bob')
      expect(@fired).to eq(true)
      expect(@changed_value).to eq('Bob')
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash = {name: 'John'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.merge!({name: 'Jon'}, {name: 'Bob'})
      expect(@fired).to eq(true)
      expect(@changed_value).to eq('Bob')
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash = {name: 'John'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.merge!({name: 'Sid'}) {|key, old_value, new_value| 'Bob' if new_value == 'Sid'}
      expect(@fired).to eq(true)
      expect(@changed_value).to eq('Bob')
      expect(@changed_key).to eq(:name)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = 'John'
      hash.add_observer(observer) # observe all keys

      hash.merge!(name: 'Bob')
      expect(@fired).to eq(true)
      expect(@changed_value).to eq('Bob')
      expect(@changed_key).to eq(:name)
    end
    
    it 'does not notify observers when Hash#merge! is called and previous key value remains the same' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.merge!(name: 'John')
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = 'John'
      hash.add_observer(observer) # observe all keys

      hash.merge!(name: 'John')
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#replace is called and changes key value' do
      @fired = false
      @changed_values = []
      @changed_keys = []
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_values << value
        @changed_keys << key
      end
      hash = {address: 'Los Angeles, California, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)
      hash.add_observer(observer, :address)

      hash.replace(name: 'John')
      expect(@fired).to eq(true)
      expect(@changed_values).to eq([nil, 'John'])
      expect(@changed_keys).to eq([:address, :name])

      @fired = false
      @changed_values = []
      @changed_keys = []
      hash.remove_observer(observer, :name)
      hash.remove_observer(observer, :address)
      hash.delete(:name)
      hash[:address] = 'Los Angeles, California, USA'
      hash.add_observer(observer) # observe all keys

      hash.replace(name: 'John')
      expect(@fired).to eq(true)
      expect(@changed_values).to eq([nil, 'John'])
      expect(@changed_keys).to eq([:address, :name])
    end
    
    it 'does not notify observers when Hash#replace is called and previous key value remains the same' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.replace(name: 'John')
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash[:name] = 'John'
      hash.add_observer(observer) # observe all keys

      hash.replace(name: 'John')
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#transform_keys! is called and changes key value' do
      @fired = false
      @changed_values = []
      @changed_keys = []
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_values << value
        @changed_keys << key
      end
      hash = {address: 'Los Angeles, California, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :location)
      hash.add_observer(observer, :address)

      hash.transform_keys! { |key| :location }
      expect(@fired).to eq(true)
      expect(@changed_values).to eq([nil, 'Los Angeles, California, USA'])
      expect(@changed_keys).to eq([:address, :location])

      @fired = false
      @changed_values = []
      @changed_keys = []
      hash.remove_observer(observer, :location)
      hash.remove_observer(observer, :address)
      hash.delete(:location)
      hash[:address] = 'Los Angeles, California, USA'
      hash.add_observer(observer) # observe all keys

      hash.transform_keys! { |key| :location }
      expect(@fired).to eq(true)
      expect(@changed_values).to eq([nil, 'Los Angeles, California, USA'])
      expect(@changed_keys).to eq([:address, :location])
    end
    
    it 'does not notify observers when Hash#transform_keys! is called and previous key value remains the same' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.transform_keys! {|key| :name}
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash.add_observer(observer) # observe all keys

      hash.transform_keys! {|key| :name}
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
    
    it 'notifies observers when Hash#transform_values! is called and changes key value' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {address: 'Los Angeles, California, USA'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :address)

      hash.transform_values! { |key| 'New York, New York, USA' }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq('New York, New York, USA')
      expect(@changed_key).to eq(:address)

      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :address)
      hash[:address] = 'Los Angeles, California, USA'
      hash.add_observer(observer) # observe all keys

      hash.transform_values! { |key| 'New York, New York, USA' }
      expect(@fired).to eq(true)
      expect(@changed_value).to eq('New York, New York, USA')
      expect(@changed_key).to eq(:address)
    end
    
    it 'does not notify observers when Hash#transform_values! is called and previous key value remains the same' do
      @fired = false
      @changed_value = nil
      @changed_key = nil
      observer = Glimmer::DataBinding::Observer.proc do |value, key|
        @fired = true
        @changed_value = value
        @changed_key = key
      end
      hash = {name: 'John'}
      hash.singleton_class.include(described_class)
      hash.add_observer(observer, :name)

      hash.transform_values! {|key| 'John'}
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
      
      @fired = false
      @changed_value = nil
      @changed_key = nil
      hash.remove_observer(observer, :name)
      hash.add_observer(observer) # observe all keys

      hash.transform_values! {|key| 'John'}
      expect(@fired).to eq(false)
      expect(@changed_value).to eq(nil)
      expect(@changed_key).to eq(nil)
    end
  end
end
