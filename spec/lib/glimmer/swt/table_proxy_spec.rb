require 'spec_helper'

module GlimmerSpec
  describe Glimmer::SWT::TableProxy do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :name

        def initialize(name)
          @name = name
        end
      end

      class Company
        attr_accessor :name, :coworkers

        def initialize(coworkers)
          @coworkers = coworkers
        end
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

    it 'is used with table expression' do
      @target = shell {
        @table = table {
        }
        @text = text {
        }
      }
      expect(@table).to be_a(described_class)
      expect(@text).to be_a(Glimmer::SWT::WidgetProxy)
    end

    describe '#search' do
      let(:person1) { Person.new('Sean') }
      let(:person2) { Person.new('Chuck') }
      let(:person3) { Person.new('John') }
      let(:person4) { Person.new('Mark') }
      let(:person5) { Person.new('Derrick') }
      let(:person6) { Person.new('Juana') }
      
      let(:company1) do 
        Company.new([person1, person2, person3, person4, person5, person6])
      end

      before do
        @target = shell {
          @table = table {
            table_column {
              text 'Name'
              width 120
            }
            items bind(company1, :coworkers), column_properties(:name)
          }
        }
      end

      it 'finds table items by block condition' do
        table_items = @table.search { |table_item| table_item.getText.start_with?('J') }

        expect(table_items.map(&:getText)).to eq(['John', 'Juana'])
      end

      it 'finds no table items' do
        table_items = @table.search { |table_item| table_item.getText.start_with?('Z') }

        expect(table_items).to be_empty
      end

      it 'gets all table items by not passing a condition block' do
        table_items = @table.search

        expect(table_items.map(&:getText)).to eq(['Sean', 'Chuck', 'John', 'Mark', 'Derrick', 'Juana'])
      end
    end
  end
end
