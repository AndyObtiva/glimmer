## NOTE: Unsupported in Ruby 2 syntax
# require "spec_helper"
#
# require_relative "../../lib/shine"
#
# describe "Glimmer Shine Data Binding" do
#   include Glimmer
#
# 	include_package 'org.eclipse.swt'
# 	include_package 'org.eclipse.swt.swt_widgets'
# 	include_package 'org.eclipse.swt.layout'
#
# 	after do
#   	@target.dispose if @target
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
#     expect(@text.swt_widget.getText).to eq( "Bruce Ting")
#
#     person.name = "Lady Butterfly"
#     expect(@text.swt_widget.getText).to eq( "Lady Butterfly")
#
#     @text.swt_widget.setText("Allen Cork")
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
#     [@text,      :text]      <=> [person, :age, on_write: :to_i]
#     [@check_box, :selection] <=> [person, :adult]
#
#     expect(@label.swt_widget.getText).to eq( "Nancy")
#     expect(@text.swt_widget.getText).to eq( "15")
#     expect(@check_box.swt_widget.getSelection).to eq( true)
#
#     person.name = "Drew"
#     expect(@label.swt_widget.getText).to eq( "Drew")
#
#     person.age = 27
#     expect(@text.swt_widget.getText).to eq( "27")
#
#     person.adult = false
#     expect(@check_box.swt_widget.getSelection).to eq( false)
#
#     @text.swt_widget.setText("30")
#     expect(person.age).to eq( 30)
#
#     @check_box.swt_widget.setSelection(true)
#     @check_box.swt_widget.notifyListeners(SWT::Selection, nil)
#     expect(person.adult).to eq( true)
#   end
#
# end
