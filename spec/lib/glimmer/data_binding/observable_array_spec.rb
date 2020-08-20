require 'spec_helper'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_array'

module Glimmer
  module DataBinding
    describe ObservableModel do
      let(:project1) {::Project.new('Home Improvement')}
      let(:project_task1) {::ProjectTask.new('Design Decorations', project1, 'High')}
      let(:project_task2) {::ProjectTask.new('Paint Wall', project1, 'High')}
      let(:project_task3) {::ProjectTask.new('Design Garage', project1, 'Medium')}
    
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
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          @fired = false
          array.first.name = 'Build Decorations'
          expect(@fired).to eq(true)
          
          @fired = false
          array.first.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.first.priority = 'Medium'
          expect(@fired).to eq(true)
          
          array << project_task2
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.last.priority = 'Medium'
          expect(@fired).to eq(true)
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
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])
          array.remove_observer(observer, [:priority])

          @fired = false
          array.first.name = 'Build Decorations'
          expect(@fired).to eq(true)
          
          @fired = false
          array.first.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.first.priority = 'Medium'
          expect(@fired).to eq(false)
          
          array << project_task2
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
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array << project_task2
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.last.priority = 'Medium'
          expect(@fired).to eq(true)        
        end  
        
        it 'notifies observers when Array#push is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.push(project_task2)
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.last.priority = 'Medium'
          expect(@fired).to eq(true)
        end    
        
        it 'notifies observers when Array#[]= is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array[0]
          array[0] = project_task3
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
          expect(@fired).to eq(false)
          
          @fired = false
          array.last.priority = 'Medium'
          expect(@fired).to eq(true)        

          @fired = false
          array[1] = project_task2
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          array.last.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.last.priority = 'Medium'
          expect(@fired).to eq(true)        
        end    
        
        it 'notifies observers when Array#pop is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
            array.add_observer(observer, [:name, :priority])

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
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

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
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

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
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

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
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

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
        
        it 'notifies observers when Array#reverse! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.reverse!
        end    
                
        xit 'notifies observers when Array#collect! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])
          
          old_element = array.first
          array.collect!(&:project)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(false)          
          
          new_element = array.first
          
          @fired = false
          new_element.name = 'Garage Improvement'
          expect(@fired).to eq(true)
        end    
                
        xit 'notifies observers when Array#collect! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.reverse!
        end    
                
      end      
      
    end
    
  end
  
end
