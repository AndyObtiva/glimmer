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
        
        it 'notifies observers when Array#append is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.append(project_task2)
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
        
        it 'notifies observers when Array#shift is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
            array.add_observer(observer, [:name, :priority])

          old_element = array.shift
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
          expect(@fired).to eq(true)
        end
                
        it 'notifies observers when Array#collect! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])
          
          old_element = array.first
          array.collect!(&:project)
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(false)
          
          new_element = array.first
          
          @fired = false
          new_element.name = 'Garage Improvement'
          expect(@fired).to eq(true)
        end
                
        it 'notifies observers when Array#map! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])
          
          old_element = array.first
          array.map!(&:project)
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(false)
          
          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(false)
          
          new_element = array.first
          
          @fired = false
          new_element.name = 'Garage Improvement'
          expect(@fired).to eq(true)
        end
                
        it 'notifies observers when Array#compact! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1, nil]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.compact!
          expect(@fired).to eq(true)
        end
        
        it 'notifies observers when Array#flatten! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          } # TODO extract to let variable
          inner_array = [project_task1]
          array = [inner_array]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])
          
          array << nil
          expect(@fired).to eq(true)
          
          @fired = false
          element = inner_array.first
          array.flatten!
          expect(@fired).to eq(true)
          
          @fired = false
          element.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          element.priority = 'Medium'
          expect(@fired).to eq(true)
        end
       
        it 'notifies observers when Array#flatten!(level) is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          } # TODO extract to let variable
          inner_array = [project_task1]
          array = [[inner_array]]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])
          
          array << nil
          expect(@fired).to eq(true)
          
          @fired = false
          element = inner_array.first
          array.flatten!(1)
          expect(@fired).to eq(true)
          
          @fired = false
          element.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          element.priority = 'Medium'
          expect(@fired).to eq(true)
        end
       
        it 'notifies observers when Array#rotate! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.rotate!
          expect(@fired).to eq(true)
        end
        
        it 'notifies observers when Array#select! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array.first
          array.select! {|pt| pt.name == 'Some Name'}
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
                
        it 'notifies observers when Array#filter! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array.first
          array.filter! {|pt| pt.name == 'Some Name'}
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
                
        it 'notifies observers when Array#shuffle! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.shuffle!
          expect(@fired).to eq(true)
        end
        
        it 'notifies observers when Array#slice!(index) is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array.first
          array.slice!(0)
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
          
        it 'notifies observers when Array#slice!(start, length) is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array.first
          array.slice!(0, 1)
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
          
        it 'notifies observers when Array#slice!(range) is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array.first
          array.slice!(0..1)
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
          
        it 'notifies observers when Array#sort! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.sort! {|a, b| a <=> b}
          expect(@fired).to eq(true)
        end
                
        it 'notifies observers when Array#sort_by! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.sort_by! {|e| e.priority}
          expect(@fired).to eq(true)
        end

        it 'notifies observers when Array#uniq! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1, project_task1.clone]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array.last
          array.uniq!
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

          element = array.first
                              
          @fired = false
          element.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          element.priority = 'Medium'
          expect(@fired).to eq(true)
        end
        
        it 'notifies observers when Array#unshift is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.unshift(project_task2)
          expect(@fired).to eq(true)
          
          @fired = false
          array.first.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          array.first.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.first.priority = 'Medium'
          expect(@fired).to eq(true)
        end
                                          
        it 'notifies observers when Array#prepend is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          array.prepend(project_task2)
          expect(@fired).to eq(true)
          
          @fired = false
          array.first.name = 'Paint Car'
          expect(@fired).to eq(true)
          
          @fired = false
          array.first.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)
          
          @fired = false
          array.first.priority = 'Medium'
          expect(@fired).to eq(true)
        end
                                          
        it 'notifies observers when Array#reject! is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array.first
          array.reject! {|pt| pt.name == 'Design Decorations'}
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
                                          
        it 'notifies observers when Array#replace is called' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array.first
          array.replace([project_task2])
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
