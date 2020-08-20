require 'spec_helper'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_model'

describe Glimmer::DataBinding::Observable do
  before :all do
    class Task
      include Glimmer::DataBinding::Observable
      attr_accessor :name
      
      def hash
        256
      end      
    end
  end
  
  after :all do
    Object.send(:remove_const, :Task) if Object.const_defined?(:Task)
  end
  
  it 'adds observer' do
    expect {Task.new.add_observer(Object.new, Object.new)}.to raise_error('Not implemented!')
  end

  it 'removes observer' do
    expect {Task.new.remove_observer(Object.new, Object.new)}.to raise_error('Not implemented!')
  end

  it 'builds inspect string from class name and hexadecimal hash value only' do
    expect(Task.new.inspect).to eq('#<Task:0x100>')
  end
 
end
