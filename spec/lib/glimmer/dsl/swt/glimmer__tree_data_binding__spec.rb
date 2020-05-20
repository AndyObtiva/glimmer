require 'spec_helper'

module GlimmerSpec
  describe "Glimmer Tree Data Binding" do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :name, :age, :adult, :coworkers
      end

      class Manager < Person
        attr_accessor :coworkers
        
        def initialize
          @coworkers = []
        end
      end

      class Company
        attr_accessor :selected_coworker
        attr_accessor :owner
        
        def initialize
          @owner = []
        end
      end

      class CompanyGroup
        attr_accessor :companies
        
        def initialize
          @companies = []
        end
      end

      class ::RedTree
        include Glimmer::UI::CustomWidget

        body {
          tree(swt_style) {
            background :red
          }
        }
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

    it "data binds tree widget to a string property" do
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
      manager.coworkers << person1
      manager.coworkers << person2

      company = Company.new
      company.owner = manager
      company.selected_coworker = person2

      company_group = CompanyGroup.new
      company_group.companies << company
      
      @target = shell {
      
      # TODO make this modification to test data-binding in the other direction (from view to model)
#         @tree = tree(:virtual, :border, :edit_on_single_click) {
#           items bind(company, :owner), tree_properties(children: :coworkers, text: :name)
#         }
      
        @tree = tree {
          items bind(company, :owner), tree_properties(children: :coworkers, text: :name)
          selection bind(company, :selected_coworker)
        }
      }
      
      expect(@tree.swt_widget).to have_style(:border)
      expect(@tree.swt_widget).to have_style(:virtual)
      expect(@tree.swt_widget).to have_style(:v_scroll)
      expect(@tree.swt_widget).to have_style(:h_scroll)

      expect(@tree.swt_widget.getItems.size).to eq(1)

      root_node = @tree.swt_widget.getItems[0]
      expect(root_node.getText).to eq("Tim Harkins")

      expect(root_node.getItems.size).to eq(2)
      node1 = root_node.getItems[0]
      node2 = root_node.getItems[1]
      expect(node1.getText).to eq("Bruce Ting")
      expect(node2.getText).to eq("Julia Fang")
      
      selection = @tree.swt_widget.getSelection
      expect(selection.size).to eq(1)
      expect(selection.first.getData).to eq(person2)
                  
      expect(@tree.tree_editor_text_proxy).to be_nil
      @write_done = false
      @tree.edit_selected_tree_item(after_write: -> { @write_done = true })
      expect(@tree.tree_editor_text_proxy).to_not be_nil
      @tree.tree_editor_text_proxy.swt_widget.setText('Julie Fan')
      # simulate hitting enter to trigger write action
      event = Event.new
      event.keyCode = Glimmer::SWT::SWTProxy[:cr]
      event.doit = true
      event.character = "\n"
      event.display =@tree.tree_editor_text_proxy.swt_widget.getDisplay
      event.item = @tree.tree_editor_text_proxy.swt_widget
      event.widget = @tree.tree_editor_text_proxy.swt_widget
      event.type = Glimmer::SWT::SWTProxy[:keydown]
      @tree.tree_editor_text_proxy.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:keydown], event)
      expect(@write_done).to eq(true)
      expect(person2.name).to eq('Julie Fan')      

      manager.name = "Tim Lee Harkins"

      root_node = @tree.swt_widget.getItems.first
      expect(root_node.getText).to eq("Tim Lee Harkins")

      person1.name = "Bruce A. Ting"
      node1 = @tree.swt_widget.getItems.first.getItems.first
      expect(node1.getText).to eq("Bruce A. Ting")

      person2.name = "Julia Katherine Fang"
      node2 = @tree.swt_widget.getItems.first.getItems.last
      expect(node2.getText).to eq("Julia Katherine Fang")

      person3 = Person.new
      person3.name = "Bob David Kennith"
      person3.age = 37
      person3.adult = true

      old_coworkers = manager.coworkers.clone

      manager.coworkers << person3

      root_node = @tree.swt_widget.getItems.first
      expect(root_node.getItems.size).to eq(3)
      node3 = root_node.getItems.last
      expect(node3.getText).to eq("Bob David Kennith")
      
      manager.coworkers = old_coworkers
      
      root_node = @tree.swt_widget.getItems.first
      expect(root_node.getItems.size).to eq(2)
      expect(root_node.getText).to eq("Tim Lee Harkins")

      person1.name = "Bruce A. Ting"
      node1 = @tree.swt_widget.getItems.first.getItems.first
      expect(node1.getText).to eq("Bruce A. Ting")

      person2.name = "Julia Katherine Fang"
      node2 = @tree.swt_widget.getItems.first.getItems.last
      expect(node2.getText).to eq("Julia Katherine Fang")

      manager.coworkers << person3
      manager.coworkers.delete_at(0)

      root_node = @tree.swt_widget.getItems.first
      expect(root_node.getItems.size).to eq(2)
      node1 = root_node.getItems.first
      node2 = root_node.getItems.last
      expect(node1.getText).to eq("Julia Katherine Fang")
      expect(node2.getText).to eq("Bob David Kennith")
    end
    
    #TODO test case when no tree item is selected to edit
    
    it "data binds tree widget to an indexed string property" do
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
      manager.coworkers << person1
      manager.coworkers << person2

      company = Company.new
      company.owner = manager

      company_group = CompanyGroup.new
      company_group.companies << company

      @target = shell {
        @tree_nested_indexed = tree(:virtual, :border) {
          items bind(company_group, "companies[0].owner"), tree_properties(children: :coworkers, text: :name)
        }
      }

      expect(@tree_nested_indexed.swt_widget.getItems.size).to eq(1)

      manager.name = "Tim Lee Harkins"

      root_node_nested_indexed = @tree_nested_indexed.swt_widget.getItems[0]
      expect(root_node_nested_indexed.getText).to eq("Tim Lee Harkins")

      person1.name = "Bruce A. Ting"
      node1_nested_indexed = @tree_nested_indexed.swt_widget.getItems.first.getItems.first
      expect(node1_nested_indexed.getText).to eq("Bruce A. Ting")

      person2.name = "Julia Katherine Fang"
      node2_nested_indexed = @tree_nested_indexed.swt_widget.getItems.first.getItems.last
      expect(node2_nested_indexed.getText).to eq("Julia Katherine Fang")

      person3 = Person.new
      person3.name = "Bob David Kennith"
      person3.age = 37
      person3.adult = true

      old_coworkers = manager.coworkers.clone

      manager.coworkers << person3

      root_node_nested_indexed = @tree_nested_indexed.swt_widget.getItems.first
      expect(root_node_nested_indexed.getItems.size).to eq(3)
      node3_nested_indexed = root_node_nested_indexed.getItems.last
      expect(node3_nested_indexed.getText).to eq("Bob David Kennith")
      
      manager.coworkers = old_coworkers
      
      root_node_nested_indexed = @tree_nested_indexed.swt_widget.getItems[0]
      expect(root_node_nested_indexed.getText).to eq("Tim Lee Harkins")

      person1.name = "Bruce A. Ting"
      node1_nested_indexed = @tree_nested_indexed.swt_widget.getItems.first.getItems.first
      expect(node1_nested_indexed.getText).to eq("Bruce A. Ting")

      person2.name = "Julia Katherine Fang"
      node2_nested_indexed = @tree_nested_indexed.swt_widget.getItems.first.getItems.last
      expect(node2_nested_indexed.getText).to eq("Julia Katherine Fang")

      manager.coworkers << person3
      manager.coworkers.delete_at(0)

      root_node_nested_indexed = @tree_nested_indexed.swt_widget.getItems.first
      expect(root_node_nested_indexed.getItems.size).to eq(2)
      node1_nested_indexed = root_node_nested_indexed.getItems.first
      node2_nested_indexed = root_node_nested_indexed.getItems.last
      expect(node1_nested_indexed.getText).to eq("Julia Katherine Fang")
      expect(node2_nested_indexed.getText).to eq("Bob David Kennith")
    end
    
    it "data binds tree widget to a string property for a custom widget tree" do
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
      manager.coworkers << person1
      manager.coworkers << person2

      company = Company.new
      company.owner = manager

      company_group = CompanyGroup.new
      company_group.companies << company

      @target = shell {
        @tree = red_tree(:virtual, :border) {
          items bind(company, :owner), tree_properties(children: :coworkers, text: :name)
        }
      }

      expect(@tree.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(@tree.swt_widget.getItems.size).to eq(1)

      root_node = @tree.swt_widget.getItems[0]
      expect(root_node.getText).to eq("Tim Harkins")

      expect(root_node.getItems.size).to eq(2)
      node1 = root_node.getItems[0]
      node2 = root_node.getItems[1]
      expect(node1.getText).to eq("Bruce Ting")
      expect(node2.getText).to eq("Julia Fang")
    end

    it 'stores models as tree item data' do
      person1 = Manager.new
      person1.name = 'Sean'

      person2 = Manager.new
      person2.name = 'Chuck'

      person3 = Manager.new
      person3.name = 'Mark'
      person4 = Manager.new
      person4.name = 'Derrick'

      person2.coworkers = [person3, person4]

      person1.coworkers = [person2]

      company1 = Company.new
      company1.owner = person1

      @target = shell {
        @tree = tree {
          items bind(company1, :owner), tree_properties(children: :coworkers, text: :name)
        }
      }

      person1_tree_item = @tree.swt_widget.getItems.first
      expect(person1_tree_item.getData).to eq(person1)

      person2_tree_item = person1_tree_item.getItems.first
      expect(person2_tree_item.getData).to eq(person2)

      person3_tree_item = person2_tree_item.getItems.first
      expect(person3_tree_item.getData).to eq(person3)
      
      person4_tree_item = person2_tree_item.getItems.last
      expect(person4_tree_item.getData).to eq(person4)      
    end
  end
end
