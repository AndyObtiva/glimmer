require 'spec_helper'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_model'

describe Glimmer::DataBinding::ObservableModel do
  before :all do
    module TaskModule
      class << self
        attr_accessor :name_filter
      end
    end
    
    class Task
      attr_accessor :name, :subtasks
      
      class << self
        attr_accessor :name_filter
      end
    end
    
    class TaskStruct < Struct.new(:name, :subtasks)
    end
    
    class TaskOpenStruct
    end
  end
  
  after :all do
    Object.send(:remove_const, :Task) if Object.const_defined?(:Task)
    Object.send(:remove_const, :TaskModule) if Object.const_defined?(:TaskModule)
  end
  
  context 'Object (instance)' do
    it 'adds observer' do
      task = Task.new
      @observer_called = nil
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(task, :name)
      task.name = 'Sean'
      expect(@observer_called).to eq('Sean')
    end
    
    it 'adds observer to Array property' do
      task = Task.new
      task.name = 'Sean'
      task.subtasks = ['subtask1', 'subtask2']
      @observer_called = nil
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(task, :subtasks)
      task.subtasks << 'subtask3'
      expect(@observer_called).to eq(['subtask1', 'subtask2', 'subtask3'])
    end
    
    it 'adds observer to Array of Arrays property recursively' do
      task = Task.new
      task.name = 'Sean'
      task.subtasks = [[['subtask1', 'subtask2']]]
      @observer_called = nil
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      
      observer.observe(task, :subtasks, recursive: true)
      task.subtasks[0][0] << 'subtask4'
      expect(@observer_called).to eq([[["subtask1", "subtask2", "subtask4"]]])
      
      task.subtasks = [[["subtask1", "subtask2", "subtask3"]]]
      @observer_called = nil
      task.subtasks[0][0][0] = 'subtask4'
      expect(@observer_called).to eq([[["subtask4", "subtask2", "subtask3"]]])
    end
    
    it 'fails to add observer to immutable object since it will not have changes' do
      model = :some_symbol
      expect {
        Glimmer::DataBinding::Observer.proc {}.observe(model, :to_s)
      }.to raise_error(TypeError)
    end
    
    it 'silently ignores adding observer to immutable object when :ignore_frozen option is specified' do
      model = :some_symbol
      expect {
        Glimmer::DataBinding::Observer.proc {}.observe(model, :to_s, ignore_frozen: true)
      }.to_not raise_error(TypeError)
    end
    
    it 'fails to add observer to frozen object since it will not have changes' do
      model = {}
      model.freeze
      expect {
        Glimmer::DataBinding::Observer.proc {}.observe(model, :to_s)
      }.to raise_error(FrozenError)
    end
    
    it 'silently ignores adding observer to frozen object when :ignore_frozen option is specified' do
      model = {}
      model.freeze
      expect {
        Glimmer::DataBinding::Observer.proc {}.observe(model, :to_s, ignore_frozen: true)
      }.to_not raise_error(FrozenError)
    end
    
    it 'removes observer' do
      task = Task.new
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      observer.unobserve(task, :name)
      task.name = 'Sean'
      expect(@observer_called).to be_nil
    end
    
    it 'removes observer for an array property' do
      task = Task.new
      task.subtasks = ['subtask1', 'subtask2']
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :subtasks)
      observer.unobserve(task, :subtasks)
      task.subtasks << 'Sean'
      expect(@observer_called).to be_nil
    end
    
    it 'removes observers for a property' do
      task = Task.new
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      task.remove_observers(:name)
      task.name = 'Sean'
      expect(@observer_called).to be_nil
    end
    
    it 'removes all observers for all properties' do
      task = Task.new
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      observer.observe(task, :subtasks)
      task.remove_all_observers
      task.name = 'Sean'
      task.subtasks = ['subtask1', 'subtask2']
      expect(@observer_called).to be_nil
    end
    
    it 'checks if object has observer for any property' do
      task = Task.new
      @observer_called = nil
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      expect(task.has_observer_for_any_property?(observer)).to eq(true)
      observer.unobserve(task, :name)
      expect(task.has_observer_for_any_property?(observer)).to eq(false)
    end
  end
  
  context 'Struct (instance)' do
    it 'adds observer' do
      task = TaskStruct.new
      @observer_called = nil
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(task, :name)
      task[:name] = 'Sean'
      expect(@observer_called).to eq('Sean')
    end
    
    it 'adds observer to Array property' do
      task = TaskStruct.new
      task[:name] = 'Sean'
      task[:subtasks] = ['subtask1', 'subtask2']
      @observer_called = nil
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(task, :subtasks)
      task[:subtasks] << 'subtask3'
      expect(@observer_called).to eq(['subtask1', 'subtask2', 'subtask3'])
    end

    it 'adds observer to Array of Arrays property recursively' do
      task = TaskStruct.new
      task[:name] = 'Sean'
      task['subtasks'] = [[['subtask1', 'subtask2']]]
      @observer_called = nil
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end

      observer.observe(task, :subtasks)
      task['subtasks'][0][0] << 'subtask3'
      expect(@observer_called).to be_nil

      observer.unobserve(task, :subtasks)

      observer.observe(task, :subtasks, recursive: true)
      task[:subtasks][0][0] << 'subtask4'
      expect(@observer_called).to eq([[["subtask1", "subtask2", "subtask3", "subtask4"]]])
    end

    it 'removes observer' do
      task = TaskStruct.new
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      observer.unobserve(task, :name)
      task[:name] = 'Sean'
      expect(@observer_called).to be_nil
    end

    it 'removes observer for an array property' do
      task = TaskStruct.new
      task['subtasks'] = ['subtask1', 'subtask2']
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :subtasks)
      observer.unobserve(task, :subtasks)
      task['subtasks'] << 'Sean'
      expect(@observer_called).to be_nil
    end

    it 'removes observers for a property' do
      task = TaskStruct.new
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      task.remove_observers(:name)
      task[:name] = 'Sean'
      expect(@observer_called).to be_nil
    end

    it 'removes all observers for all properties' do
      task = TaskStruct.new
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

    it 'checks if object has observer for any property' do
      task = TaskStruct.new
      @observer_called = nil
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      expect(task.has_observer_for_any_property?(observer)).to eq(true)
      observer.unobserve(task, :name)
      expect(task.has_observer_for_any_property?(observer)).to eq(false)
    end
  end
  
  context 'OpenStruct (instance)' do
    it 'adds observer' do
      task = OpenStruct.new
      @observer_called = nil
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(task, :name)
      task[:name] = 'Sean'
      expect(@observer_called).to eq('Sean')
    end
    
    it 'adds observer to Array property' do
      task = OpenStruct.new
      task[:name] = 'Sean'
      task[:subtasks] = ['subtask1', 'subtask2']
      @observer_called = nil
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(task, :subtasks)
      task[:subtasks] << 'subtask3'
      expect(@observer_called).to eq(['subtask1', 'subtask2', 'subtask3'])
    end

    it 'adds observer to Array of Arrays property recursively' do
      task = OpenStruct.new
      task[:name] = 'Sean'
      task['subtasks'] = [[['subtask1', 'subtask2']]]
      @observer_called = nil
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end

      observer.observe(task, :subtasks)
      task['subtasks'][0][0] << 'subtask3'
      expect(@observer_called).to be_nil

      observer.unobserve(task, :subtasks)

      observer.observe(task, :subtasks, recursive: true)
      task[:subtasks][0][0] << 'subtask4'
      expect(@observer_called).to eq([[["subtask1", "subtask2", "subtask3", "subtask4"]]])
    end

    it 'removes observer' do
      task = OpenStruct.new
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      observer.unobserve(task, :name)
      task[:name] = 'Sean'
      expect(@observer_called).to be_nil
    end

    it 'removes observer for an array property' do
      task = OpenStruct.new
      task['subtasks'] = ['subtask1', 'subtask2']
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :subtasks)
      observer.unobserve(task, :subtasks)
      task['subtasks'] << 'Sean'
      expect(@observer_called).to be_nil
    end

    it 'removes observers for a property' do
      task = OpenStruct.new
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      task.remove_observers(:name)
      task[:name] = 'Sean'
      expect(@observer_called).to be_nil
    end

    it 'removes all observers for all properties' do
      task = OpenStruct.new
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

    it 'checks if object has observer for any property' do
      task = OpenStruct.new
      @observer_called = nil
      observer = Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end
      observer.observe(task, :name)
      expect(task.has_observer_for_any_property?(observer)).to eq(true)
      observer.unobserve(task, :name)
      expect(task.has_observer_for_any_property?(observer)).to eq(false)
    end
  end
  
  context 'class' do
    it 'adds observer' do
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(Task, :name_filter)
      Task.name_filter = 'Se'
      expect(@observer_called).to eq('Se')
    end
  end
  
  context 'module' do
    it 'adds observer' do
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(TaskModule, :name_filter)
      TaskModule.name_filter = 'Se'
      expect(@observer_called).to eq('Se')
    end
  end
end
