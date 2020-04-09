require "spec_helper"

module GlimmerSpec
  describe "Glimmer Listeners" do
    include Glimmer

    before(:all) do
      class Person
        attr_accessor :name, :age, :adult
      end

      class ::RedButton
        include Glimmer::SWT::CustomWidget

        def body
          button(swt_style) {
            background :red
          }
        end
      end
    end

    after(:all) do
      Object.send(:remove_const, :Person) if Object.const_defined?(:Person)
      Object.send(:remove_const, :RedButton) if Object.const_defined?(:RedButton)
    end

    after do
      @target.dispose if @target
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

      @text.widget.setText("Hi")
      expect(@text.widget.getText).to eq("Hi")

      @text.widget.setText("Hello")
      expect(@text.widget.getText).to eq("Hi")
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
      @button.widget.setSelection(true)
      @button.widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
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

      expect(@button.widget.getBackground).to eq(Glimmer::SWT::GColor.color_for(:red))
      expect(person.name).to eq("Bruce Ting")
      @button.widget.setSelection(true)
      @button.widget.notifyListeners(Glimmer::SWT::SWTProxy[:selection], nil)
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
        @button.widget.setVisible(true)
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
              end.to raise_error(RuntimeError)
            }
          }
        }
      end
    end
  end
end
