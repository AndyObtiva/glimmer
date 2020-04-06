require "spec_helper"

module GlimmerSpec
  describe "Glimmer Tree Data Binding" do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :name, :age, :adult, :people
      end

      class Manager < Person
        def initialize
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

      class CompanyGroup
        def initialize
          @companies = []
        end

        attr_accessor :companies
      end

      class ::RedTree
        include Glimmer::SWT::CustomWidget

        def body
          tree(swt_style) {
            background :red
          }
        end
      end
    end

    after(:all) do
      %w[
        Person
        Manager
        Company
        RedTree
      ].each do |constant|
        Object.send(:remove_const, constant) if Object.const_defined?(constant)
      end
    end

    after do
      @target.dispose if @target
    end

    it "data binds text widget to a string property" do
      person1 = Person.new
      person1.name = "Bruce Ting"
      person1.age = 45
      person1.adult = true

      person2 = Person.new
      person2.name = "Julia Fang"
      person2.age = 17
      person2.adult = false

      manager = Manager.new
      manager.name = "Tim Harkins"
      manager.age = 79
      manager.adult = true
      manager.people << person1
      manager.people << person2

      company = Company.new
      company.owner = manager

      company_group = CompanyGroup.new
      company_group.companies << company

      @target = shell {
        @tree = tree(:virtual, :border) {
          items bind(company, :owner), tree_properties(children: :people, text: :name)
        }
        @tree_nested_indexed = tree(:virtual, :border) {
          items bind(company_group, "companies[0].owner"), tree_properties(children: :people, text: :name)
        }
      }

      expect(@tree.widget.getItems.size).to eq(1)
      expect(@tree_nested_indexed.widget.getItems.size).to eq(1)

      root_node = @tree.widget.getItems[0]
      expect(root_node.getText()).to eq("Tim Harkins")

      expect(root_node.getItems.size).to eq(2)
      node1 = root_node.getItems[0]
      node2 = root_node.getItems[1]
      expect(node1.getText()).to eq("Bruce Ting")
      expect(node2.getText()).to eq("Julia Fang")

      manager.name = "Tim Lee Harkins"

      root_node = @tree.widget.getItems[0]
      expect(root_node.getText()).to eq("Tim Lee Harkins")
      root_node_nested_indexed = @tree_nested_indexed.widget.getItems[0]
      expect(root_node_nested_indexed.getText()).to eq("Tim Lee Harkins")

      person1.name = "Bruce A. Ting"
      node1 = @tree.widget.getItems.first.getItems.first
      expect(node1.getText()).to eq("Bruce A. Ting")
      node1_nested_indexed = @tree_nested_indexed.widget.getItems.first.getItems.first
      expect(node1_nested_indexed.getText()).to eq("Bruce A. Ting")

      person2.name = "Julia Katherine Fang"
      node2 = @tree.widget.getItems.first.getItems.last
      expect(node2.getText()).to eq("Julia Katherine Fang")
      node2_nested_indexed = @tree_nested_indexed.widget.getItems.first.getItems.last
      expect(node2_nested_indexed.getText()).to eq("Julia Katherine Fang")

      person3 = Person.new
      person3.name = "Bob David Kennith"
      person3.age = 37
      person3.adult = true

      manager.people << person3
      manager.people = manager.people

      root_node = @tree.widget.getItems.first
      expect(root_node.getItems.size).to eq(3)
      node3 = root_node.getItems.last
      expect(node3.getText()).to eq("Bob David Kennith")
      root_node_nested_indexed = @tree_nested_indexed.widget.getItems.first
      expect(root_node_nested_indexed.getItems.size).to eq(3)
      node3_nested_indexed = root_node_nested_indexed.getItems.last
      expect(node3_nested_indexed.getText()).to eq("Bob David Kennith")

      manager.people.delete_at(0)

      root_node = @tree.widget.getItems.first
      expect(root_node.getItems.size).to eq(2)
      node1 = root_node.getItems.first
      node2 = root_node.getItems.last
      expect(node1.getText()).to eq("Julia Katherine Fang")
      expect(node2.getText()).to eq("Bob David Kennith")
      root_node_nested_indexed = @tree_nested_indexed.widget.getItems.first
      expect(root_node_nested_indexed.getItems.size).to eq(2)
      node1_nested_indexed = root_node_nested_indexed.getItems.first
      node2_nested_indexed = root_node_nested_indexed.getItems.last
      expect(node1_nested_indexed.getText()).to eq("Julia Katherine Fang")
      expect(node2_nested_indexed.getText()).to eq("Bob David Kennith")
    end

    it "data binds text widget to a string property for a custom widget tree" do
      person1 = Person.new
      person1.name = "Bruce Ting"
      person1.age = 45
      person1.adult = true

      person2 = Person.new
      person2.name = "Julia Fang"
      person2.age = 17
      person2.adult = false

      manager = Manager.new
      manager.name = "Tim Harkins"
      manager.age = 79
      manager.adult = true
      manager.people << person1
      manager.people << person2

      company = Company.new
      company.owner = manager

      company_group = CompanyGroup.new
      company_group.companies << company

      @target = shell {
        @tree = red_tree(:virtual, :border) {
          items bind(company, :owner), tree_properties(children: :people, text: :name)
        }
      }

      expect(@tree.widget.getBackground).to eq(Glimmer::SWT::GColor.color_for(:red))
      expect(@tree.widget.getItems.size).to eq(1)

      root_node = @tree.widget.getItems[0]
      expect(root_node.getText()).to eq("Tim Harkins")

      expect(root_node.getItems.size).to eq(2)
      node1 = root_node.getItems[0]
      node2 = root_node.getItems[1]
      expect(node1.getText()).to eq("Bruce Ting")
      expect(node2.getText()).to eq("Julia Fang")
    end
  end
end
