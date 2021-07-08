require 'spec_helper'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/shine'

describe Glimmer::DataBinding::Shine do
  before(:all) do
    class Person
      attr_accessor :name
    end
    
    # Fakes a view coming from the GLimmer GUI DSL
    class View
      attr_reader :model_binding
      attr_accessor :args
    
      def initialize(parent_attribute)
        @parent_attribute = parent_attribute
      end
    
      def text(model_binding)
        @model_binding = model_binding
      end
      
      def bind(*args)
        Glimmer::DataBinding::ModelBinding.new(*args)
      end
      
      def content(&block)
        instance_exec(&block)
      end
    end
  end
  
  after(:all) do
    Object.send(:remove_const, :Person) if Object.constants.include?(:Person)
    Object.send(:remove_const, :View) if Object.constants.include?(:View)
  end
  
  let(:person) do
    Person.new.tap do |p|
      p.name = 'Carl'
    end
  end
  
  let(:view) do
    View.new('text')
  end
  
  subject do
    described_class.new(view, 'text')
  end

  it 'data-binds bidirectionally' do
    subject <=> [person, 'name']
    
    expect(view.model_binding).to be_a(Glimmer::DataBinding::ModelBinding)
    expect(view.model_binding.evaluate_property).to eq(person.name)
    expect(view.model_binding.binding_options).to eq({})
  end
  
  it 'data-binds unidirectionally' do
    subject <= [person, 'name']
    
    expect(view.model_binding).to be_a(Glimmer::DataBinding::ModelBinding)
    expect(view.model_binding.evaluate_property).to eq(person.name)
    expect(view.model_binding.binding_options).to eq({read_only: true})
  end

end
