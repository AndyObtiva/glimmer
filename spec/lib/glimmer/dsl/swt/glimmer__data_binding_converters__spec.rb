require 'spec_helper'

module GlimmerSpec
  describe "Glimmer Data Binding Converters" do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :name, :age, :spouse
      end
    end

    after(:all) do
      %w[
        Person
      ].each do |constant|
        Object.send(:remove_const, constant) if Object.const_defined?(constant)
      end
    end

    it "converts value on write to model via value method symbol" do
      person = Person.new

      @target = shell {
        composite {
          @text = text {
            text bind(person, :age, on_write: :to_i)
          }
        }
      }

      @text.swt_widget.setText("30")
      expect(person.age).to eq(30)
    end

    it "converts value on write to model with lambda" do
      person = Person.new

      @target = shell {
        composite {
          @text = text {
            text bind(person, :age, on_write: lambda {|a| a.to_i})
          }
        }
      }

      @text.swt_widget.setText("30")
      expect(person.age).to eq(30)
    end

    it "raises a Glimmer:Error if on_write converter is an invalid value method symbol" do
      person = Person.new

      @target = shell {
        composite {
          @text = text {
            text bind(person, :age, on_write: :to_garbage)
          }
        }
      }

      expect {
        @text.swt_widget.setText("30")
      }.to raise_error(Glimmer::Error)
    end

    it "raises a Glimmer:Error if on_write converter is an invalid object" do
      person = Person.new

      @target = shell {
        composite {
          @text = text {
            text bind(person, :age, on_write: 33)
          }
        }
      }

      expect {
        @text.swt_widget.setText("30")
      }.to raise_error(Glimmer::Error)
    end

    it "converts value on write to widget using built-in default widget property data-binding converter" do
      person = Person.new
      person.age = 15

      @target = shell {
        composite {
          @text = text {
            text bind(person, :age)
          }
        }
      }

      expect(@text.swt_widget.getText).to eq("15")

      person.age = 27
      expect(@text.swt_widget.getText).to eq("27")
    end

    it "converts value on read from model via value method symbol" do
      person = Person.new
      person.name = 'Sean McFaun'

      @target = shell {
        composite {
          @text = text {
            text bind(person, :name, on_read: :upcase)
          }
        }
      }

      expect(@text.swt_widget.getText).to eq('SEAN MCFAUN')

      person.name = 'Johnny Francone'
      expect(@text.swt_widget.getText).to eq('JOHNNY FRANCONE')
    end

    it "converts value on read from model with lambda" do
      person = Person.new
      person.name = 'Sean McFaun'

      @target = shell {
        composite {
          @text = text {
            text bind(person, :name, on_read: lambda {|n| n.split(' ').first})
          }
        }
      }

      expect(@text.swt_widget.getText).to eq('Sean')

      person.name = 'Johnny Francone'
      expect(@text.swt_widget.getText).to eq('Johnny')
    end

    it "converts value on read from model with block shortcut syntax" do
      person = Person.new
      person.name = 'Sean McFaun'

      @target = shell {
        composite {
          @text = text {
            text bind(person, :name) {|n| n.split(' ').first}
          }
        }
      }

      expect(@text.swt_widget.getText).to eq('Sean')

      person.name = 'Johnny Francone'
      expect(@text.swt_widget.getText).to eq('Johnny')
    end

    it "converts nil value on read from model" do
      person = Person.new
      person.name = 'John'
      spouse = Person.new
      spouse.name = 'Mary'
      person.spouse = spouse

      @target = shell {
        composite {
          @text = text {
            text bind(person, :name) {|n| n.nil? ? 'ANONYMOUS' : n.upcase}
          }
          @text2 = text {
            text bind(person, 'spouse.name') {|n| n.nil? ? 'ANONYMOUS' : n.upcase}
          }
        }
      }

      expect(@text.swt_widget.getText).to eq('JOHN')
      expect(@text2.swt_widget.getText).to eq('MARY')

      person.name = 'Johnny'
      expect(@text.swt_widget.getText).to eq('JOHNNY')
      spouse.name = 'Marianne'
      expect(@text2.swt_widget.getText).to eq('MARIANNE')

      person.name = nil
      expect(@text.swt_widget.getText).to eq('ANONYMOUS')
      person.spouse = nil
      expect(@text2.swt_widget.getText).to eq('ANONYMOUS')
    end

    it "converts value on read and write from model via value method symbols" do
      person = Person.new
      person.name = 'Sean McFaun'

      @target = shell {
        composite {
          @text = text {
            text bind(person, :name, on_read: :upcase, on_write: :downcase)
          }
        }
      }

      expect(@text.swt_widget.getText).to eq('SEAN MCFAUN')

      @text.swt_widget.setText("Provan McCullough")
      expect(person.name).to eq('provan mccullough')
      expect(@text.swt_widget.getText).to eq('PROVAN MCCULLOUGH')
    end

    it "converts value on read and write from model via lambdas" do
      person = Person.new
      person.name = 'Sean McFaun'

      @target = shell {
        composite {
          @text = text {
            text bind(person, :name, on_read: lambda {|n| n.upcase}, on_write: lambda {|n| n.downcase})
          }
        }
      }

      expect(@text.swt_widget.getText).to eq('SEAN MCFAUN')

      @text.swt_widget.setText("Provan McCullough")
      expect(person.name).to eq('provan mccullough')
      expect(@text.swt_widget.getText).to eq('PROVAN MCCULLOUGH')
    end
  end
end
