require "spec_helper"
require 'os'

module GlimmerSpec
  describe "Glimmer Listeners" do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :name, :age, :adult
      end

      class ::RedButton
        include Glimmer::UI::CustomWidget

        body {
          button(swt_style) {
            background :red
          }
        }
      end
    end

    after(:all) do
      Object.send(:remove_const, :Person) if Object.const_defined?(:Person)
      Object.send(:remove_const, :RedButton) if Object.const_defined?(:RedButton)
    end

    it "tests text widget verify listener" do
      @target = shell {
        composite {
          @text = text {
            text "Howdy"
            on_verify_text do |verify_event|
              verify_event.doit = false if verify_event.text == "Hello"
            end
          }
        }
      }

      @text.swt_widget.setText("Hi")
      expect(@text.swt_widget.getText).to eq("Hi")

      @text.swt_widget.setText("Hello")
      expect(@text.swt_widget.getText).to eq("Hi")
    end

    it "tests button widget selection listener" do
      person = Person.new
      person.name = "Bruce Ting"

      @target = shell {
        composite {
          @button = button {
            on_widget_selected do
              person.name = "Bruce Lao"
            end
          }
        }
      }
      expect(person.name).to eq("Bruce Ting")
      @button.swt_widget.setSelection(true)
      @button.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.name).to eq("Bruce Lao")
    end

    it "tests button widget selection listener on a custom widget button" do
      person = Person.new
      person.name = "Bruce Ting"

      @target = shell {
        composite {
          @button = red_button {
            on_widget_selected do
              person.name = "Bruce Lao"
            end
          }
        }
      }

      expect(@button.swt_widget.getBackground).to eq(Glimmer::SWT::ColorProxy.new(:red).swt_color)
      expect(person.name).to eq("Bruce Ting")
      @button.swt_widget.setSelection(true)
      @button.swt_widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
      expect(person.name).to eq("Bruce Lao")
    end

    context "SWT event listener (hooked with addListener(SWT.Style, listener)" do
      it "tests button SWT.Show event listener" do
        person = Person.new
        person.name = "Bruce Ting"

        @target = shell {
          composite {
            @button = button {
              visible false
              on_event_show do
                @button_shown = true
              end
            }
          }
        }

        expect(@button_shown).to eq(nil)
        @button.swt_widget.setVisible(true)
        expect(@button_shown).to eq(true)
      end

      it "fails in adding button SWT.invalid event listener" do
        person = Person.new
        person.name = "Bruce Ting"

        @target = shell {
          composite {
            @button = button {
              visible false
              expect do
                on_event_invalid do
                  @button_shown = true
                end
              end.to raise_error(Glimmer::Error)
            }
          }
        }
      end
    end

    context 'Shell listeners for Application Menu Items' do
      it 'listens to about menu item selection' do
        if OS.mac?
          system_menu = Glimmer::SWT::DisplayProxy.instance.swt_display.getSystemMenu
          about_menu_item = system_menu.getItems.find {|menu_item| menu_item.getID == swt('ID_ABOUT')}
          expect(about_menu_item.getListeners(swt(:Selection)).count).to eq(0)
        end
        @target = display {
          on_about {
            # No Op
          }
        }
        if OS.mac?
	       expect(about_menu_item.getListeners(swt(:Selection)).count).to eq(1)
        end	
      end
      it 'listens to preferences menu item selection' do
        if OS.mac?
          system_menu = Glimmer::SWT::DisplayProxy.instance.swt_display.getSystemMenu
          preferences_menu_item = system_menu.getItems.find {|menu_item| menu_item.getID == swt('ID_PREFERENCES')}
          expect(preferences_menu_item.getListeners(swt(:Selection)).count).to eq(0)
        end
        @target = display {
          on_preferences {
            # No Op
          }
        }
        if OS.mac?
          expect(preferences_menu_item.getListeners(swt(:Selection)).count).to eq(1)
        end
      end
    end
  end
end
