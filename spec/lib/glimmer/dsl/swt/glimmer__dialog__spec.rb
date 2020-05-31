require "spec_helper"

module GlimmerSpec
  describe "Glimmer Dialog" do
    include Glimmer

    it 'renders a dialog having dialog trim and application modal styles' do
      @target = dialog

      expect(@target).to be_a(Glimmer::SWT::ShellProxy)
      expect(@target.swt_widget).to be_a(Shell)
      expect(@target.swt_widget).to have_style(:dialog_trim)
      expect(@target.swt_widget).to have_style(:application_modal)
    end
    
    it 'renders a dialog under a shell' do
      @target = shell {
        @dialog = dialog {
          text 'Hello, World!'
          @label = label
        }
      }

      expect(@dialog).to be_a(Glimmer::SWT::ShellProxy)
      expect(@dialog.swt_widget).to be_a(Shell)
      expect(@dialog.swt_widget).to have_style(:dialog_trim)
      expect(@dialog.swt_widget).to have_style(:application_modal)
      expect(@dialog.swt_widget.getParent).to eq(@target.swt_widget)
      expect(@dialog.swt_widget.getText).to eq('Hello, World!')
      expect(@label.swt_widget.getParent).to eq(@dialog.swt_widget)
    end
    
    it 'renders a dialog nested explicitly under a shell via argument' do
      @target = shell
      @dialog = dialog(@target)

      expect(@dialog).to be_a(Glimmer::SWT::ShellProxy)
      expect(@dialog.swt_widget).to be_a(Shell)
      expect(@dialog.swt_widget).to have_style(:dialog_trim)
      expect(@dialog.swt_widget).to have_style(:application_modal)
      expect(@dialog.swt_widget.getParent).to eq(@target.swt_widget)
    end
  end
end
