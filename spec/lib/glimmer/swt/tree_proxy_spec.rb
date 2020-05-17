require 'spec_helper'

module GlimmerSpec
  describe Glimmer::SWT::TreeProxy do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :name

        def initialize(name)
          @name = name
        end
      end

      class Manager < Person
        def initialize(name)
          super
          @people = []
        end

        attr_accessor :people
      end

      class Company
        def initialize
          @owner = []
        end

        attr_accessor :owner
      end
    end

    after(:all) do
      %w[
        Person
        Manager
        Company
      ].each do |constant|
        Object.send(:remove_const, constant) if Object.const_defined?(constant)
      end
    end

    it 'is used with tree expression' do
      @target = shell {
        @tree = tree {
        }
        @text = text {
        }
      }
      expect(@tree).to be_a(described_class)
      expect(@text).to be_a(Glimmer::SWT::WidgetProxy)
    end

    describe '#select' do
      it 'selects a tree item node by text' do
        person1 = Manager.new('Sean')

        person2 = Manager.new('Chuck')
        person4 = Manager.new('Mark')
        person5 = Manager.new('Derrick')
        person2.people = [person4, person5]

        person3 = Manager.new('John')
        person6 = Manager.new('Juana')
        person3.people = [person6]

        person1.people = [person2, person3]

        company1 = Company.new
        company1.owner = person1

        @target = shell {
          @tree = tree {
            items bind(company1, :owner), tree_properties(children: :people, text: :name)
          }
        }
        
        @tree.select(text: 'Juana')

        person6_tree_item = @tree.swt_widget.getItems.first.getItems.last.getItems.first
        expect(person6_tree_item.getText).to eq('Juana')
        expect(@tree.swt_widget.getItems.first.getItems.last.getItems).to eq(@tree.swt_widget.getSelection)
      end
    end
  end
end
