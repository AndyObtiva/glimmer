## NOTE: Unsupported in Ruby 2 syntax
# require "spec_helper"
#
# require_relative "../../lib/shine"
#
# describe "Glimmer Shine Data Binding" do
#   include Glimmer
#
# 	include_package 'org.eclipse.swt'
# 	include_package 'org.eclipse.swt.widgets'
# 	include_package 'org.eclipse.swt.layout'
#
# 	after do
#   	@target.display.dispose if @target.display
# 	end
#
#   class Person
#     attr_accessor :name, :age, :adult
#   end
#
#   it "tests text_widget_data_binding_string_property_spaceship" do
#     person = Person.new
#     person.name = "Bruce Ting"
#
#     @target = shell {
#       composite {
#         @text = text {
#         }
#       }
#     }
#
#     [@text, :text] <=> [person, :name]
#
#     expect(@text.widget.getText).to eq( "Bruce Ting")
#
#     person.name = "Lady Butterfly"
#     expect(@text.widget.getText).to eq( "Lady Butterfly")
#
#     @text.widget.setText("Allen Cork")
#     expect(person.name).to eq( "Allen Cork")
#
#     comparison = ["he"] <=> ["he"]
#     expect(comparison).to eq(0)
#   end
#
#   it "tests multiple_widget_data_bindings_to_different_model_properties_spaceship" do
#     person = Person.new
#     person.name = "Nancy"
#     person.age = 15
#     person.adult = true
#
#     @target = shell {
#       composite {
#         @label = label {}
#         @text = text {}
#         @check_box = button(:check) {}
#       }
#     }
#
#     [@label,     :text]      <=> [person, :name]
#     [@text,      :text]      <=> [person, :age, :fixnum]
#     [@check_box, :selection] <=> [person, :adult]
#
#     expect(@label.widget.getText).to eq( "Nancy")
#     expect(@text.widget.getText).to eq( "15")
#     expect(@check_box.widget.getSelection).to eq( true)
#
#     person.name = "Drew"
#     expect(@label.widget.getText).to eq( "Drew")
#
#     person.age = 27
#     expect(@text.widget.getText).to eq( "27")
#
#     person.adult = false
#     expect(@check_box.widget.getSelection).to eq( false)
#
#     @text.widget.setText("30")
#     expect(person.age).to eq( 30)
#
#     @check_box.widget.setSelection(true)
#     @check_box.widget.notifyListeners(SWT::Selection, nil)
#     expect(person.adult).to eq( true)
#   end
#
# end
