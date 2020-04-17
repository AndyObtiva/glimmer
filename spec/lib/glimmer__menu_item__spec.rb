require "spec_helper"

module GlimmerSpec
  describe "Glimmer Menu Item" do
    include Glimmer

    before(:all) do
      class ::RedShell
        include Glimmer::UI::CustomShell

        body {
          shell {
            background :red
          }
        }
      end
      class ::HistoryMenu
        include Glimmer::UI::CustomWidget

        body {
          menu {
            text '&History'
          }
        }
      end
    end

    after(:all) do
      Object.send(:remove_const, :RedShell) if Object.const_defined?(:RedShell)
      Object.send(:remove_const, :HistoryMenu) if Object.const_defined?(:HistoryMenu)
    end

    context 'SWT shell/menu parents' do
      it "renders menu bar" do
        @target = shell {
          @menu_bar = menu_bar {
            menu {
              text "&File"
              menu_item {
                text "E&xit"
              }
              menu_item(0) {
                text "&New"
              }
              menu(1) {
                text "&Options"
                menu_item(:radio) {
                  text "Option 1"
                }
                menu_item(:separator)
                menu_item(:check) {
                  text "Option 3"
                }
              }
            }
            menu {
              text "&History"
              menu {
                text "&Recent"
                menu_item {
                  text "File 1"
                }
                menu_item {
                  text "File 2"
                }
              }
            }
          }
        }

        expect(@menu_bar).to be_a(Glimmer::SWT::MenuProxy)
        expect(@menu_bar.swt_widget).to have_style(:bar)
        expect(@target.swt_widget.getMenuBar).to eq(@menu_bar.swt_widget)
        expect(@menu_bar.swt_widget.getItems.size).to eq(2)

        menu_item1 = @menu_bar.swt_widget.getItems[0]
        expect(menu_item1.getText).to eq("&File")
        expect(menu_item1).to have_style(:cascade)
        menu_item2 = @menu_bar.swt_widget.getItems[1]
        expect(menu_item2.getText).to eq("&History")
        expect(menu_item2).to have_style(:cascade)

        menu1 = menu_item1.getMenu
        expect(menu1).to have_style(:drop_down)
        expect(menu1.getItems.size).to eq(3)
        menu1_menu_item1 = menu1.getItems[0]
        expect(menu1_menu_item1.getText).to eq('&New')
        expect(menu1_menu_item1).to have_style(:push)
        menu1_menu_item2 = menu1.getItems[1]
        expect(menu1_menu_item2.getText).to eq('&Options')
        expect(menu1_menu_item2).to have_style(:cascade)
        menu1_menu_item3 = menu1.getItems[2]
        expect(menu1_menu_item3.getText).to eq('E&xit')
        expect(menu1_menu_item3).to have_style(:push)

        menu1_menu2 = menu1_menu_item2.getMenu
        expect(menu1_menu2).to have_style(:drop_down)
        menu1_menu2_menu_item1 = menu1_menu2.getItems[0]
        expect(menu1_menu2_menu_item1.getText).to eq('Option 1')
        expect(menu1_menu2_menu_item1).to have_style(:radio)
        menu1_menu2_menu_item2 = menu1_menu2.getItems[1]
        expect(menu1_menu2_menu_item2).to have_style(:separator)
        menu1_menu2_menu_item3 = menu1_menu2.getItems[2]
        expect(menu1_menu2_menu_item3.getText).to eq('Option 3')
        expect(menu1_menu2_menu_item3).to have_style(:check)

        menu2 = menu_item2.getMenu
        expect(menu2).to have_style(:drop_down)
        menu2_menu_item1 = menu2.getItems[0]
        expect(menu2_menu_item1).to have_style(:cascade)
        expect(menu2_menu_item1.getText).to eq("&Recent")
        menu2_menu1_menu1 = menu2_menu_item1.getMenu
        expect(menu2_menu1_menu1).to have_style(:drop_down)
        menu2_menu1_menu1_menu_item1 = menu2_menu1_menu1.getItems[0]
        expect(menu2_menu1_menu1_menu_item1.getText).to eq('File 1')
        expect(menu2_menu1_menu1_menu_item1).to have_style(:push)
        menu2_menu1_menu1_menu_item2 = menu2_menu1_menu1.getItems[1]
        expect(menu2_menu1_menu1_menu_item2.getText).to eq('File 2')
        expect(menu2_menu1_menu1_menu_item2).to have_style(:push)
      end

      it "renders pop up menu" do
        @target = shell {
          @pop_up_menu = menu {
            menu {
              text '&History'
              menu {
                text "&Recent"
                menu_item {
                  text "File 1"
                }
                menu_item {
                  text "File 2"
                }
              }
            }
          }
        }

        expect(@pop_up_menu).to be_a(Glimmer::SWT::MenuProxy)
        expect(@pop_up_menu.swt_widget).to have_style(:pop_up)
        expect(@target.swt_widget.getMenu).to eq(@pop_up_menu.swt_widget)
        expect(@pop_up_menu.swt_widget.getItems.size).to eq(1)

        menu_item2 = @pop_up_menu.swt_widget.getItems[0]
        expect(menu_item2.getText).to eq("&History")
        expect(menu_item2).to have_style(:cascade)

        menu2 = menu_item2.getMenu
        expect(menu2).to have_style(:drop_down)
        menu2_menu_item1 = menu2.getItems[0]
        expect(menu2_menu_item1).to have_style(:cascade)
        expect(menu2_menu_item1.getText).to eq("&Recent")
        menu2_menu1_menu1 = menu2_menu_item1.getMenu
        expect(menu2_menu1_menu1).to have_style(:drop_down)
        menu2_menu1_menu1_menu_item1 = menu2_menu1_menu1.getItems[0]
        expect(menu2_menu1_menu1_menu_item1.getText).to eq('File 1')
        expect(menu2_menu1_menu1_menu_item1).to have_style(:push)
        menu2_menu1_menu1_menu_item2 = menu2_menu1_menu1.getItems[1]
        expect(menu2_menu1_menu1_menu_item2.getText).to eq('File 2')
        expect(menu2_menu1_menu1_menu_item2).to have_style(:push)
      end
    end

    context 'Custom shell/menu parents' do
      it "renders menu bar" do
        @target = red_shell {
          @menu_bar = menu_bar {
            menu {
              text "&File"
              menu_item {
                text "E&xit"
              }
              menu_item(0) {
                text "&New"
              }
              menu(1) {
                text "&Options"
                menu_item(:radio) {
                  text "Option 1"
                }
                menu_item(:separator)
                menu_item(:check) {
                  text "Option 3"
                }
              }
            }
            history_menu {
              menu {
                text "&Recent"
                menu_item {
                  text "File 1"
                }
                menu_item {
                  text "File 2"
                }
              }
            }
          }
        }

        expect(@menu_bar).to be_a(Glimmer::SWT::MenuProxy)
        expect(@menu_bar.swt_widget).to have_style(:bar)
        expect(@target.swt_widget.getMenuBar).to eq(@menu_bar.swt_widget)
        expect(@menu_bar.swt_widget.getItems.size).to eq(2)

        menu_item1 = @menu_bar.swt_widget.getItems[0]
        expect(menu_item1.getText).to eq("&File")
        expect(menu_item1).to have_style(:cascade)
        menu_item2 = @menu_bar.swt_widget.getItems[1]
        expect(menu_item2.getText).to eq("&History")
        expect(menu_item2).to have_style(:cascade)

        menu1 = menu_item1.getMenu
        expect(menu1).to have_style(:drop_down)
        expect(menu1.getItems.size).to eq(3)
        menu1_menu_item1 = menu1.getItems[0]
        expect(menu1_menu_item1.getText).to eq('&New')
        expect(menu1_menu_item1).to have_style(:push)
        menu1_menu_item2 = menu1.getItems[1]
        expect(menu1_menu_item2.getText).to eq('&Options')
        expect(menu1_menu_item2).to have_style(:cascade)
        menu1_menu_item3 = menu1.getItems[2]
        expect(menu1_menu_item3.getText).to eq('E&xit')
        expect(menu1_menu_item3).to have_style(:push)

        menu1_menu2 = menu1_menu_item2.getMenu
        expect(menu1_menu2).to have_style(:drop_down)
        menu1_menu2_menu_item1 = menu1_menu2.getItems[0]
        expect(menu1_menu2_menu_item1.getText).to eq('Option 1')
        expect(menu1_menu2_menu_item1).to have_style(:radio)
        menu1_menu2_menu_item2 = menu1_menu2.getItems[1]
        expect(menu1_menu2_menu_item2).to have_style(:separator)
        menu1_menu2_menu_item3 = menu1_menu2.getItems[2]
        expect(menu1_menu2_menu_item3.getText).to eq('Option 3')
        expect(menu1_menu2_menu_item3).to have_style(:check)

        menu2 = menu_item2.getMenu
        expect(menu2).to have_style(:drop_down)
        menu2_menu_item1 = menu2.getItems[0]
        expect(menu2_menu_item1).to have_style(:cascade)
        expect(menu2_menu_item1.getText).to eq("&Recent")
        menu2_menu1_menu1 = menu2_menu_item1.getMenu
        expect(menu2_menu1_menu1).to have_style(:drop_down)
        menu2_menu1_menu1_menu_item1 = menu2_menu1_menu1.getItems[0]
        expect(menu2_menu1_menu1_menu_item1.getText).to eq('File 1')
        expect(menu2_menu1_menu1_menu_item1).to have_style(:push)
        menu2_menu1_menu1_menu_item2 = menu2_menu1_menu1.getItems[1]
        expect(menu2_menu1_menu1_menu_item2.getText).to eq('File 2')
        expect(menu2_menu1_menu1_menu_item2).to have_style(:push)
      end

      it "renders pop up menu" do
        @target = red_shell {
          @pop_up_menu = menu {
            history_menu {
              menu {
                text "&Recent"
                menu_item {
                  text "File 1"
                }
                menu_item {
                  text "File 2"
                }
              }
            }
          }
        }

        expect(@pop_up_menu).to be_a(Glimmer::SWT::MenuProxy)
        expect(@pop_up_menu.swt_widget).to have_style(:pop_up)
        expect(@target.swt_widget.getMenu).to eq(@pop_up_menu.swt_widget)
        expect(@pop_up_menu.swt_widget.getItems.size).to eq(1)

        menu_item2 = @pop_up_menu.swt_widget.getItems[0]
        expect(menu_item2.getText).to eq("&History")
        expect(menu_item2).to have_style(:cascade)

        menu2 = menu_item2.getMenu
        expect(menu2).to have_style(:drop_down)
        menu2_menu_item1 = menu2.getItems[0]
        expect(menu2_menu_item1).to have_style(:cascade)
        expect(menu2_menu_item1.getText).to eq("&Recent")
        menu2_menu1_menu1 = menu2_menu_item1.getMenu
        expect(menu2_menu1_menu1).to have_style(:drop_down)
        menu2_menu1_menu1_menu_item1 = menu2_menu1_menu1.getItems[0]
        expect(menu2_menu1_menu1_menu_item1.getText).to eq('File 1')
        expect(menu2_menu1_menu1_menu_item1).to have_style(:push)
        menu2_menu1_menu1_menu_item2 = menu2_menu1_menu1.getItems[1]
        expect(menu2_menu1_menu1_menu_item2.getText).to eq('File 2')
        expect(menu2_menu1_menu1_menu_item2).to have_style(:push)
      end
    end
  end
end
