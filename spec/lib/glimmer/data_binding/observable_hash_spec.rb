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
    
    it 'adds observer to Hash key value' do
      task = {}
      task[:name] = 'Sean'
      task[:subtasks] = {subtask1: 'thesubtask1', subtask2: 'thesubtask2'}
      @observer_called = nil
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(task, :subtasks)
      task[:subtasks][:subtask3] = 'thesubtask3'
      expect(@observer_called).to eq({subtask1: 'thesubtask1', subtask2: 'thesubtask2', subtask3: 'thesubtask3'})
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
  end
end
