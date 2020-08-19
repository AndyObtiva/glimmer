require 'spec_helper'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_array'

module Glimmer
  module DataBinding
    describe ObservableModel do
      before :all do
        ::ProjectTask = Struct.new(:name, :project_name, :priority)
      end
      
      after :all do
        Object.send(:remove_const, :ObservableTask) if Object.const_defined?(:Task)
      end
    
      describe '#add_observer' do
        it 'adds observer without element properties' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = []
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer)
          expect(@fired).to eq(false)
          array << 'element'
          expect(@fired).to eq(true)
        end
        
        it 'adds observer with element properties' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])

          @fired = false
          array.first.name = 'Build Decorations'
          expect(@fired).to eq(true)
          
          @fired = false
          array.first.project_name = 'Garage Improvement'
          expect(@fired).to eq(true)
          
          @fired = false
          array.first.priority = 'Medium'
          expect(@fired).to eq(false)
          
          array << ProjectTask.new('Paint Wall', 'Home Improvement', 'High')
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.project_name = 'Garage Improvement'
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.priority = 'Medium'
          expect(@fired).to eq(false)
        end
      end  
    
    end
  end
end
