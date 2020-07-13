require 'spec_helper'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_model'

describe Glimmer::DataBinding::ObservableModel do
  before :all do
    class Task
      attr_accessor :name
      
      class << self
        attr_accessor :name_filter
      end
    end
  end
  
  after :all do
    Object.send(:remove_const, :Task) if Object.const_defined?(:Task)
  end
  
  context 'object (instance)' do
    it 'adds observer' do
      task = Task.new
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_called = new_value
      end.observe(task, :name)
      task.name = 'Sean'
      expect(@observer_called).to eq('Sean')
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
end
