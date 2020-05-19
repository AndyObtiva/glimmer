require 'spec_helper'

module GlimmerSpec
  describe Glimmer::SWT::TreeProxy do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :name, :coworkers

        def initialize(name)
          @name = name
          @coworkers = []
        end
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

    describe '#depth_first_search' do
      let(:person4) {Person.new('Mark')}
      let(:person5) {Person.new('Derrick')}
      let(:person2) do 
        Person.new('Chuck').tap do |person|
          person.coworkers = [person4, person5]
        end
      end
      let(:person6) { Person.new('Juana') }
      let(:person3) do
        Person.new('John').tap do |person|
          person.coworkers = [person6]
        end
      end
      let(:person1) do 
        Person.new('Sean').tap do |person|
          person.coworkers = [person2, person3]
        end
      end
      let(:company1) do 
        Company.new.tap do |company|
          company.owner = person1
        end
      end

      before do
        @target = shell {
          @tree = tree {
            items bind(company1, :owner), tree_properties(children: :coworkers, text: :name)
          }
        }
      end

      it 'finds tree items by block condition' do
        tree_items = @tree.depth_first_search { |tree_item| tree_item.getText.start_with?('J') }

        expect(tree_items.map(&:getText)).to eq(['John', 'Juana'])
      end

      it 'finds no tree items' do
        tree_items = @tree.depth_first_search { |tree_item| tree_item.getText.start_with?('Z') }

        expect(tree_items).to be_empty
      end

      it 'gets all tree items by not passing a condition block' do
        tree_items = @tree.depth_first_search

        expect(tree_items.map(&:getText)).to eq(%w[Sean Chuck Mark Derrick John Juana])
      end
    end
  end
end
