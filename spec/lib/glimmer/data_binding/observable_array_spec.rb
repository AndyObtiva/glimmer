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
        
        it 'adds recursive observer to an array having array elements (without element properties)' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [['a', 'b']]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, recursive: true)
          expect(@fired).to eq(false)
          array[0][0] = 'c'
          expect(@fired).to eq(true)
          
          @fired = false
          old_array = array[0]
          array[0] = ['c', 'd']
          expect(@fired).to eq(true)
          
          @fired = false
          old_array << 'e'
          expect(@fired).to eq(false)
          old_array[0] << 'e'
          expect(@fired).to eq(false)
        end
        
        it 'adds recursive observer to an array having array elements (without element properties) using alternate syntax' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [['a', 'b']]
          observer.observe(array, recursive: true)
          expect(@fired).to eq(false)
          array[0][0] = 'c'
          expect(@fired).to eq(true)
          
          @fired = false
          old_array = array[0]
          array[0] = ['c', 'd']
          expect(@fired).to eq(true)
          
          @fired = false
          array[0][0] = 'e'
          expect(@fired).to eq(true)
          
          @fired = false
          old_array << 'e'
          expect(@fired).to eq(false)
          old_array[0] << 'e'
          expect(@fired).to eq(false)
        end
        
        it 'adds recursive observer to an empty array' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = []
          observer.observe(array, recursive: true)
          expect(@fired).to eq(false)
          array[0] = []
          expect(@fired).to eq(true)
          
          @fired = false
          array[0][0] = []
          expect(@fired).to eq(true)
          
          @fired = false
          array[0][0][0] = 'e'
          expect(@fired).to eq(true)
          
          @fired = false
          array.replace([[['e']]])
          expect(@fired).to eq(true)
        end
        
        it 'adds recursive observer (1-level only) to an array having array elements (without element properties) using alternate syntax' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [[['a', 'b']]]
          observer.observe(array, recursive: 1)
          
          @fired = false
          array[0][0][0] = 'c'
          expect(@fired).to eq(false)
          
          @fired = false
          array[0][0] = ['e', 'f']
          expect(@fired).to eq(true)
          
          @fired = false
          array[0] = [['c', 'd']]
          expect(@fired).to eq(true)
        end
        
        it 'adds non-recursive observer to an array having array elements (without element properties)' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [['a', 'b']]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer)
          expect(@fired).to eq(false)
          array[0][0] = 'c'
          expect(@fired).to eq(false)
          
          @fired = false
          old_array = array[0]
          array[0] = ['c', 'd']
          expect(@fired).to eq(true)
          
          @fired = false
          old_array << 'e'
          expect(@fired).to eq(false)
          array[0] << 'e'
          expect(@fired).to eq(false)
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
          
          array[0] = [[[project_task1]]]
          @fired = false
          array[0][0][0] << project_task2
          expect(@fired).to eq(true)
          
          old_element = array[0]
          array[0] = project_task3
          @fired = false
          old_element << project_task2
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
        
        it 'keeps observing an element that remains after replacing one occurrence' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          repeated_element = project_task1
          array = [repeated_element, repeated_element]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name])

          array[0] = project_task3
          @fired = false
          repeated_element.name = 'Still observed'
          expect(@fired).to eq(true)
        end

        it 'notifies observers when Array#insert is called with one argument' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array[0]
          array.insert(0, project_task3)
          expect(array).to eq([project_task3, project_task1])
          expect(array[1]).to eq(old_element)
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(true)

          @fired = false
          old_element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)

          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(true)
          
          @fired = false
          array[0].name = 'Power Car'
          expect(@fired).to eq(true)

          @fired = false
          array[0].project_name = 'Garage Upgrade'
          expect(@fired).to eq(false)

          @fired = false
          array[0].priority = 'Low'
          expect(@fired).to eq(true)
        end
        
        it 'notifies observers when Array#insert is called with multiple arguments' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          array = [project_task1]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name, :priority])

          old_element = array[0]
          array.insert(0, project_task2, project_task3)
          expect(array).to eq([project_task2, project_task3, project_task1])
          expect(array[2]).to eq(old_element)
          expect(@fired).to eq(true)
          
          @fired = false
          old_element.name = 'Paint Car'
          expect(@fired).to eq(true)

          @fired = false
          old_element.project_name = 'Garage Improvement'
          expect(@fired).to eq(false)

          @fired = false
          old_element.priority = 'Medium'
          expect(@fired).to eq(true)
          
          @fired = false
          array[0].name = 'Power Car'
          expect(@fired).to eq(true)

          @fired = false
          array[0].project_name = 'Garage Upgrade'
          expect(@fired).to eq(false)

          @fired = false
          array[0].priority = 'Low'
          expect(@fired).to eq(true)
          
          @fired = false
          array[1].name = 'Better Car'
          expect(@fired).to eq(true)

          @fired = false
          array[1].project_name = 'Garage Work'
          expect(@fired).to eq(false)

          @fired = false
          array[1].priority = 'High'
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
        
        it 'unobserves every equal element removed by Array#delete' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          first_element = project_task1
          equal_element = first_element.clone
          array = [first_element, equal_element]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name])

          array.delete(first_element)
          expect(array).to be_empty
          @fired = false
          equal_element.name = 'No longer observed'
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
        
        it 'unobserves only the removed identity when equal elements remain after Array#delete_if' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          removed_element = project_task1
          retained_element = removed_element.clone
          array = [removed_element, retained_element]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, [:name])

          array.delete_if { |element| element.equal?(removed_element) }
          expect(array).to eq([retained_element])

          @fired = false
          removed_element.name = 'No longer observed'
          expect(@fired).to eq(false)
          retained_element.name = 'Still observed'
          expect(@fired).to eq(true)
        end

        it 'retains recursive observation on an equal nested array after removal' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          removed_element = [1]
          retained_element = [1]
          array = [removed_element, retained_element]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, recursive: true)

          array.delete_if { |element| element.equal?(removed_element) }
          @fired = false
          retained_element << 2
          expect(@fired).to eq(true)
        end

        it 'keeps only the retained equal nested array observed after removal' do
          @fired = false
          observer = Observer.proc {
            @fired = true
          }
          retained_element = [1]
          removed_element = [1]
          array = [retained_element, removed_element]
          array.singleton_class.include(ObservableArray)
          array.add_observer(observer, recursive: true)

          array.delete_if { |element| element.equal?(removed_element) }
          @fired = false
          retained_element << 2
          expect(@fired).to eq(true)
          @fired = false
          removed_element << 2
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
          new_element = project_task2
          array.replace([new_element])
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
          new_element.name = 'Observed after replacement'
          expect(@fired).to eq(true)
        end
                                          
      end
      
    end
    
  end
  
end
