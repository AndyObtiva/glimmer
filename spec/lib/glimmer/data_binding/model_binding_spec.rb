require 'spec_helper'
require 'glimmer/data_binding/model_binding'

describe Glimmer::DataBinding::ModelBinding do
  before(:all) do
    class Person
      attr_accessor :name, :age, :spouse, :siblings, :first_name, :last_name, :grid, :triple_grid, :hash_attribute
      
      # optionally receives hook_array for testing
      def initialize(hook_array = nil, name: nil)
        @hook_array = hook_array
        @name = name
        @siblings = []
        @grid = [['x'], ['o'], ['x']]
        @triple_grid = [[['x'], ['o'], ['x']], [['x'], ['o'], ['x']]]
        @hash_attribute = {a: 1, b: 2, c: 3, e: {ea: 5, eb: 6, ec: 7, ed: 8, ee: {eea: 9, eea: 10}}, 'a' => 1111, 'b' => {'ba' => 2222, 'bb' => {'bba' => 3333}}}
      end

      def name
        if @first_name && @last_name
          DataBindingString.new("#{@first_name} #{@last_name}", @hook_array)
        else
          @name
        end
      end
    end

    class DataBindingString < String
      def initialize(string, array)
        super(string)
        @array = array
      end
      
      def before_read
        @array << "before read"
      end
      
      def after_read
        @array << "after read"
      end
    end
  end

  after(:all) do
    %w[
      Person
      DataBindingString
    ].each do |constant|
      Object.send(:remove_const, constant) if Object.const_defined?(constant)
    end
  end
  
  let(:person) { Person.new(name: 'person') }
  let(:spouse) { Person.new(name: 'spouse') }
  let(:sibling) { Person.new(name: 'sibling') }
  let(:sibling2) { Person.new(name: 'sibling2') }
  let(:sibling3) { Person.new(name: 'sibling3') }

  context 'data-binding' do
    it 'reads changes in an array object observed directly (not as a property)' do
      model_binding = described_class.new(person.siblings)
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
      end.observe(model_binding)
      
      person.siblings << sibling
        
      expect(@observer_notified).to be_truthy
      
      new_siblings = [Person.new, Person.new]
      model_binding.call(new_siblings)
        
      # If no property is specified in ModelBinding.new, then call does nothing (it is a read only binding)
      expect(person.siblings).to_not eq(new_siblings)
    end
    
    it 'reads changes in a hash object observed directly (not as a property)' do
      model_binding = described_class.new(person.hash_attribute)
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
      end.observe(model_binding)
      
      person.hash_attribute[:somekey] = 'somevalue'
        
      expect(@observer_notified).to be_truthy
      
      new_hash = {d: 4}
      model_binding.call(new_hash)
        
      # If no property is specified in ModelBinding.new, then call does nothing (it is a read only binding)
      expect(person.hash_attribute).to_not eq(new_hash)
    end
    
    it 'reads and writes changes in an array attribute' do
      model_binding = described_class.new(person, :siblings)
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
      end.observe(model_binding)
      
      person.siblings << sibling
        
      expect(@observer_notified).to be_truthy
      
      new_siblings = [Person.new, Person.new]
      model_binding.call(new_siblings)
        
      expect(person.siblings).to eq(new_siblings)
    end
    
    it 'reads and writes changes in a hash attribute key' do
      model_binding = described_class.new(person.hash_attribute, :d)
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
      end.observe(model_binding)
      
      person.hash_attribute[:c] = 4
        
      expect(@observer_notified).to be_falsey
      
      person.hash_attribute[:d] = 4
        
      expect(@observer_notified).to be_truthy
      
      new_value = 5
      model_binding.call(new_value)
        
      expect(person.hash_attribute[:d]).to eq(new_value)
    end
    
    it 'reads and writes changes in an array-indexed model' do
      person.siblings = []
      model_binding = described_class.new(person, 'siblings[0]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.siblings << sibling
      person.siblings << sibling2
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(sibling)
      
      model_binding.call(sibling3) # updates siblings[0] only

      expect(person.siblings).to eq([sibling3, sibling2])
    end
    
    it 'reads and writes changes in a hash-symbol-indexed model' do
      person.siblings = []
      model_binding = described_class.new(person, 'hash_attribute[:a]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute[:a] = 11
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(11)
      
      model_binding.call(111)

      expect(person.hash_attribute[:a]).to eq(111)
    end
    
    it 'reads and writes changes in a hash-single-quote-string-indexed model' do
      person.siblings = []
      model_binding = described_class.new(person, "hash_attribute['a']")
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute['a'] = 11111
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(11111)
      
      model_binding.call(111111)

      expect(person.hash_attribute['a']).to eq(111111)
    end
    
    it 'reads and writes changes in a hash-double-quote-string-indexed model' do
      person.siblings = []
      model_binding = described_class.new(person, 'hash_attribute["a"]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute["a"] = 11
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(11)
      
      model_binding.call(111)

      expect(person.hash_attribute["a"]).to eq(111)
    end
    
    it 'reads and writes changes in a directly array-indexed property' do
      person.siblings = []
      model_binding = described_class.new(person.siblings, '[0]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.siblings << sibling
      person.siblings << sibling2
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(sibling)
      
      model_binding.call(sibling3) # updates siblings[0] only

      expect(person.siblings).to eq([sibling3, sibling2])
    end
    
    it 'reads and writes changes in a directly hash-symbol-indexed property' do
      person.siblings = []
      model_binding = described_class.new(person.hash_attribute, '[:a]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute[:a] = 11
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(11)
      
      model_binding.call(111)

      expect(person.hash_attribute[:a]).to eq(111)
    end
    
    it 'reads and writes changes in a directly hash-single-quote-indexed property' do
      person.siblings = []
      model_binding = described_class.new(person.hash_attribute, "['a']")
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute['a'] = 11
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(11)
      
      model_binding.call(111)

      expect(person.hash_attribute['a']).to eq(111)
    end
    
    it 'reads and writes changes in a directly hash-double-quote-indexed property' do
      person.siblings = []
      model_binding = described_class.new(person.hash_attribute, '["a"]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute["a"] = 11
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(11)
      
      model_binding.call(111)

      expect(person.hash_attribute["a"]).to eq(111)
    end
    
    it 'reads and writes changes in a directly hash-symbol-indexed property' do
      person.siblings = []
      model_binding = described_class.new(person.hash_attribute, '[:a]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute[:a] = 11
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(11)
      
      model_binding.call(111)

      expect(person.hash_attribute[:a]).to eq(111)
    end
    
    it 'reads and writes changes in an array-indexed nested model' do
      person.siblings = [sibling]
      model_binding = described_class.new(person, 'siblings[0].name')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.siblings[0].name = 'sibling2'
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq('sibling2')
      
      @observer_notified = false
      @observer_new_value = nil
      person.siblings.prepend(sibling3)
      
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq('sibling3')
      
      model_binding.call('sibling4') # updates siblings[0].name

      expect(person.siblings[0].name).to eq('sibling4')
    end
      
    it 'reads and writes changes in a directly array-indexed nested property' do
      person.siblings = [sibling]
      model_binding = described_class.new(person.siblings, '[0].name')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.siblings[0].name = 'sibling2'
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq('sibling2')
      
      @observer_notified = false
      @observer_new_value = nil
      person.siblings.prepend(sibling3)
      
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq('sibling3')
      
      model_binding.call('sibling4') # updates siblings[0].name

      expect(person.siblings[0].name).to eq('sibling4')
    end
      
    it 'reads and writes changes in an array-double-indexed model' do
      model_binding = described_class.new(person, 'grid[1][0]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.grid[1][0] = 'x'
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq('x')
      
      model_binding.call('o')

      expect(person.grid[1][0]).to eq('o')
    end
      
    it 'reads and writes changes in an hash-symbol-double-indexed model' do
      model_binding = described_class.new(person, 'hash_attribute[:e][:ea]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute[:e][:ea] = 55
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(55)
      
      model_binding.call(555)

      expect(person.hash_attribute[:e][:ea]).to eq(555)
    end
      
    it 'reads and writes changes in an hash-single-quote-double-indexed model' do
      model_binding = described_class.new(person, "hash_attribute['b']['ba']")
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute['b']['ba'] = 55
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(55)
      
      model_binding.call(555)

      expect(person.hash_attribute['b']['ba']).to eq(555)
    end
      
    it 'reads and writes changes in an hash-double-quote-double-indexed model' do
      model_binding = described_class.new(person, 'hash_attribute["b"]["ba"]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute["b"]["ba"] = 55
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(55)
      
      model_binding.call(555)

      expect(person.hash_attribute["b"]["ba"]).to eq(555)
    end
      
    it 'reads and writes changes in an array-triple-indexed model' do
      model_binding = described_class.new(person, 'triple_grid[1][1][0]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.triple_grid[1][1][0] = 'x'
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq('x')
      
      model_binding.call('o')

      expect(person.triple_grid[1][1][0]).to eq('o')
    end
      
    it 'reads and writes changes in an hash-symbol-triple-indexed model' do
      model_binding = described_class.new(person, 'hash_attribute[:e][:ee][:eea]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute[:e][:ee][:eea] = 99
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(99)
      
      model_binding.call(999)

      expect(person.hash_attribute[:e][:ee][:eea]).to eq(999)
    end
    
    it 'reads and writes changes in an hash-single-quote-triple-indexed model' do
      model_binding = described_class.new(person, "hash_attribute['b']['bb']['bba']")
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute['b']['bb']['bba'] = 55
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(55)
      
      model_binding.call(555)

      expect(person.hash_attribute['b']['bb']['bba']).to eq(555)
    end
      
    it 'reads and writes changes in an hash-double-quote-triple-indexed model' do
      model_binding = described_class.new(person, 'hash_attribute["b"]["bb"]["bba"]')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.hash_attribute["b"]["bb"]["bba"] = 55
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq(55)
      
      model_binding.call(555)

      expect(person.hash_attribute["b"]["bb"]["bba"]).to eq(555)
    end
    
    it 'reads and writes changes in a nested hash-symbol-triple-indexed model' do
      person.spouse = spouse
      spouse.hash_attribute[:e][:ee][:person] = person
      model_binding = described_class.new(person, 'spouse.hash_attribute[:e][:ee][:person].name')
      
      Glimmer::DataBinding::Observer.proc do |new_value|
        @observer_notified = true
        @observer_new_value = new_value
      end.observe(model_binding)
      
      person.spouse.hash_attribute[:e][:ee][:person].name = 'jonathan'
        
      expect(@observer_notified).to be_truthy
      expect(@observer_new_value).to eq('jonathan')
      
      model_binding.call('jared')

      expect(person.spouse.hash_attribute[:e][:ee][:person].name).to eq('jared')
    end
    
  end
  
  context 'converters' do
    it "converts value on write to model via value method symbol" do
      @model_binding = described_class.new(person, :age, on_write: :to_i)
  
      @model_binding.call('30')
      expect(person.age).to eq(30)
    end
  
    it "converts value on write to model with lambda" do
      @model_binding = described_class.new(person, :age, on_write: lambda {|a| a.to_i})
  
      @model_binding.call('30')
      expect(person.age).to eq(30)
    end
  
    it "raises a Glimmer:Error if on_write converter is an invalid value method symbol" do
      @model_binding = described_class.new(person, :age, on_write: :to_garbage)
  
      expect {
        @model_binding.call('30')
      }.to raise_error(Glimmer::Error)
    end
  
    it "raises a Glimmer:Error if on_write converter is an invalid object" do
      @model_binding = described_class.new(person, :age, on_write: 33)
  
      expect {
        @model_binding.call('30')
      }.to raise_error(Glimmer::Error)
    end
  
    it "converts value on write to widget using built-in default widget property data-binding converter" do
      person.age = 15
  
      @model_binding = described_class.new(person, :age, on_read: :to_s)
  
      expect(@model_binding.evaluate_property).to eq("15")
  
      person.age = 27
      expect(@model_binding.evaluate_property).to eq("27")
    end
  
    it "converts value on read from model via value method symbol" do
      person.name = 'Sean McFaun'
  
      @model_binding = described_class.new(person, :name, on_read: :upcase)
  
      expect(@model_binding.evaluate_property).to eq('SEAN MCFAUN')
  
      person.name = 'Johnny Francone'
      expect(@model_binding.evaluate_property).to eq('JOHNNY FRANCONE')
    end
  
    it "converts value on read from model with lambda" do
      person.name = 'Sean McFaun'
  
      @model_binding = described_class.new(person, :name, on_read: lambda {|n| n.split(' ').first})
  
      expect(@model_binding.evaluate_property).to eq('Sean')
  
      person.name = 'Johnny Francone'
      expect(@model_binding.evaluate_property).to eq('Johnny')
    end
  
    it "converts nil value on read from model" do
      person.name = 'John'
      spouse.name = 'Mary'
      person.spouse = spouse
  
      @model_binding = described_class.new(person, :name, on_read: lambda {|n| n.nil? ? 'ANONYMOUS' : n.upcase})
      @model_binding2 = described_class.new(person, 'spouse.name', on_read: lambda {|n| n.nil? ? 'ANONYMOUS' : n.upcase})
  
      expect(@model_binding.evaluate_property).to eq('JOHN')
      expect(@model_binding2.evaluate_property).to eq('MARY')
  
      person.name = 'Johnny'
      expect(@model_binding.evaluate_property).to eq('JOHNNY')
      spouse.name = 'Marianne'
      expect(@model_binding2.evaluate_property).to eq('MARIANNE')
  
      person.name = nil
      expect(@model_binding.evaluate_property).to eq('ANONYMOUS')
      person.spouse = nil
      expect(@model_binding2.evaluate_property).to eq('ANONYMOUS')
    end
  
    it "converts value on read and write from model via value method symbols" do
      person.name = 'Sean McFaun'
  
      @model_binding = described_class.new(person, :name, on_read: :upcase, on_write: :downcase)
  
      expect(@model_binding.evaluate_property).to eq('SEAN MCFAUN')
  
      @model_binding.call('Provan McCullough')
      expect(person.name).to eq('provan mccullough')
      expect(@model_binding.evaluate_property).to eq('PROVAN MCCULLOUGH')
    end
  
    it "converts value on read and write from model via lambdas" do
      person.name = 'Sean McFaun'
  
      @model_binding = described_class.new(person, :name, on_read: lambda {|n| n.upcase}, on_write: lambda {|n| n.downcase})
  
      expect(@model_binding.evaluate_property).to eq('SEAN MCFAUN')
  
      @model_binding.call('Provan McCullough')
      expect(person.name).to eq('provan mccullough')
      expect(@model_binding.evaluate_property).to eq('PROVAN MCCULLOUGH')
    end
  end
  
  context 'hooks' do
    it 'before_read and after_read' do
      array = []
      read_value = nil
      @model_binding = described_class.new(
        person,
        :name,
        before_read: lambda {|name| array << "name before read: #{name}"},
        on_read: lambda {|name| array << "name on read: #{name}"; "#{name} Jr"},
        after_read: lambda {|converted_name|
          expect(read_value).to eq('Sean McFaun Jr')
          array << "name after read: #{converted_name}"
        },
      )
      
      observer = Glimmer::DataBinding::Observer.proc { |new_value|
        read_value = new_value
      }
      observer.observe(@model_binding)

      person.name = 'Sean McFaun'

      expect(array).to eq(["name before read: Sean McFaun", "name on read: Sean McFaun", "name after read: Sean McFaun Jr"])
      
      observer.unobserve(@model_binding)

      person.name = 'Benjamin George'

      expect(array).to eq(["name before read: Sean McFaun", "name on read: Sean McFaun", "name after read: Sean McFaun Jr"])
    end
    
    it 'nested data-binding before_read and after_read without parameters' do
      person.siblings = [sibling]
      array = []
      read_value = nil
      @model_binding = described_class.new(
        person,
        'siblings[0].name',
        before_read: lambda {|name| array << "before read"},
        on_read: lambda {|name| array << "name on read: #{name}"; "#{name} II"},
        after_read: lambda {|converted_name|
          expect(read_value).to eq('Laura Magnus II')
          array << "after read"
        },
      )
      
      observer = Glimmer::DataBinding::Observer.proc { |new_value|
        read_value = new_value
      }
      observer.observe(@model_binding)

      person.siblings[0].name = 'Laura Magnus'

      expect(array).to eq(["before read", "name on read: Laura Magnus", "after read"])
      
      observer.unobserve(@model_binding)

      person.siblings[0].name = 'Lana Sears'

      person.siblings[0] = sibling2
      
      person.siblings = [sibling2]
      
      expect(array).to eq(["before read", "name on read: Laura Magnus", "after read"])
    end
    
    it 'computed data-binding before_read and after_read as methods' do
      array = []
      person = Person.new(array)
      person.first_name = 'Sean'
      last_name = 'McFaun'

      read_value = nil
      @model_binding = described_class.new(
        person,
        :name,
        computed_by: [:first_name, :last_name],
        before_read: :before_read,
        on_read: lambda {|name| array << "name on read: #{name}"; DataBindingString.new(name, array)},
        after_read: :after_read
      )
      
      observer = Glimmer::DataBinding::Observer.proc { |new_value|
        read_value = new_value
      }
      observer.observe(@model_binding)

      person.last_name = last_name

      expect(read_value).to eq('Sean McFaun')
      expect(array).to eq(["before read", "name on read: Sean McFaun", "after read"])
      
      observer.unobserve(@model_binding)
      person.last_name = 'Mickey'
      expect(read_value).to eq('Sean McFaun')
      expect(array).to eq(["before read", "name on read: Sean McFaun", "after read"])
    end
    
    it 'before_write and after_write' do
      array = []

      @model_binding = described_class.new(
        person,
        :name,
        before_write: lambda {|name| array << "name before write: #{name}"},
        on_write: lambda {|name| array << "name on write: #{name}"; "#{name} Jr"},
        after_write: lambda {|converted_name|
          expect(person.name).to eq('Sean McFaun Jr')
          array << "name after write: #{converted_name}"
        },
      )
  
      @model_binding.call('Sean McFaun')

      expect(array).to eq(["name before write: Sean McFaun", "name on write: Sean McFaun", "name after write: Sean McFaun Jr"])
    end
    
    it 'before_write and after_write without parameters' do
      array = []

      @model_binding = described_class.new(
        person,
        :name,
        before_write: lambda {array << "before write"},
        on_write: lambda {|name| array << "name on write: #{name}"; "#{name} Jr"},
        after_write: lambda {array << "after write"},
      )
  
      @model_binding.call('Sean McFaun')

      expect(person.name).to eq('Sean McFaun Jr')
      
      expect(array).to eq(["before write", "name on write: Sean McFaun", "after write"])
    end
    
    it 'before_write and after_write as methods' do
      array = []
      the_name = 'Sean McFaun'
      the_name.singleton_class.define_method(:before_write) { array << "before write"}
      the_name.singleton_class.define_method(:after_write) { array << "after write"}

      @model_binding = described_class.new(
        person,
        :name,
        before_write: :before_write,
        on_write: lambda {|name| array << "name on write: #{name}"; name},
        after_write: :after_write,
      )
  
      @model_binding.call(the_name)

      expect(person.name).to eq('Sean McFaun')
      
      expect(array).to eq(["before write", "name on write: Sean McFaun", "after write"])
    end
  end
end
