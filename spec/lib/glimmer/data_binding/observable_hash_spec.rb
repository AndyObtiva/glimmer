require 'spec_helper'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_hash'

describe Glimmer::DataBinding::ObservableHash do
  context 'object (instance)' do
    # TODO observe(task) without keys
    
    it 'adds observer' do
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
    
    it 'adds observer to array key value' do
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
end
