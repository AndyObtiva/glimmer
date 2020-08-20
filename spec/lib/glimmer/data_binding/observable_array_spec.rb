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
        Object.send(:remove_const, :ProjectTask) if Object.const_defined?(:ProjectTask)
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
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
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
          
          array << ::ProjectTask.new('Paint Wall', 'Home Improvement', 'High')
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

      describe '#remove_observer' do
        it 'removes observer without element properties' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = []
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer)
          array.remove_observer(observer)
          array << 'element'
          expect(@fired).to eq(false)
        end
        
        it 'removes observer with element properties' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])
          array.remove_observer(observer, [:project_name])

          @fired = false
          array.first.name = 'Build Decorations'
          expect(@fired).to eq(true)
          
          @fired = false
          array.first.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.first.priority = 'Medium'
          expect(@fired).to eq(false)
          
          array << ::ProjectTask.new('Paint Wall', 'Home Improvement', 'High')
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.last.priority = 'Medium'
          expect(@fired).to eq(false)
        end        
      
      end
      
      describe 'array mutation method' do
        it 'notifies observers when Array#<< is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])

          array << ::ProjectTask.new('Paint Wall', 'Home Improvement', 'High')
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
        
        it 'notifies observers when Array#push is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])

          array.push(::ProjectTask.new('Paint Wall', 'Home Improvement', 'High'))
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
        
        it 'notifies observers when Array#[]= is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])

          old_element = array[0]
          array[0] = ::ProjectTask.new('Design Garage', 'Home Improvement', 'Medium')
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(false)        
          
          @fired = false
          array.last.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.project_name = 'Garage Improvement'
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.priority = 'Medium'
          expect(@fired).to eq(false)        

          @fired = false
          array[1] = ::ProjectTask.new('Paint Wall', 'Home Improvement', 'High')
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
        
        it 'notifies observers when Array#pop is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])

          old_element = array.pop
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(false)          
        end    
        
        it 'notifies observers when Array#delete is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])

          old_element = array.delete(array.first)
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(false)          
        end    
        
        it 'notifies observers when Array#delete_at is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])

          old_element = array.delete_at(0)
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(false)          
        end    
        
        it 'notifies observers when Array#delete_if is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])

          old_element = array.first
          array.delete_if {|e| e.name.start_with?('Design')}
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(false)          
        end    
        
        it 'notifies observers when Array#clear is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [::ProjectTask.new('Design Decorations', 'Home Improvement', 'High')]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :project_name])

          old_element = array.first
          array.clear
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(false)          
        end    
        
      end      
      
    end
    
  end
  
end
