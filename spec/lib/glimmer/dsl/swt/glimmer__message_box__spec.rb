require "spec_helper"

module GlimmerSpec
  describe "Glimmer Message Box" do
    include Glimmer

    it 'renders a message box nested inside a shell' do
      @target = shell {
        @message_box = message_box {
          text 'Hello'
          message 'Hello, this is a greeting!'
        }
      }
      
      expect(@message_box).to be_a(Glimmer::SWT::MessageBoxProxy)
      expect(@message_box.swt_widget).to be_a(MessageBox)
      expect(@message_box.swt_widget.getText).to eq('Hello')
      expect(@message_box.swt_widget.getMessage).to eq('Hello, this is a greeting!')
    end    

    it 'renders a message box with style nested inside a shell' do
      @target = shell {
        @message_box = message_box(:icon_information, :yes, :no, :cancel) {
          text 'Hello'
          message 'Hello, this is a greeting!'
        }
      }
      
      expect(@message_box).to be_a(Glimmer::SWT::MessageBoxProxy)
      expect(@message_box.swt_widget).to be_a(MessageBox)
      expect(@message_box.swt_widget.getText).to eq('Hello')
      expect(@message_box.swt_widget.getMessage).to eq('Hello, this is a greeting!')
      expect(@message_box.swt_widget).to have_style(:icon_information)
      expect(@message_box.swt_widget).to have_style(:yes)
      expect(@message_box.swt_widget).to have_style(:no)
      expect(@message_box.swt_widget).to have_style(:cancel)
    end

    it 'renders a message box taking a shell as an argument' do
      @target = shell
      @message_box = message_box(@target) {
        text 'Hello'
        message 'Hello, this is a greeting!'
      }
      
      expect(@message_box).to be_a(Glimmer::SWT::MessageBoxProxy)
      expect(@message_box.swt_widget).to be_a(MessageBox)
      expect(@message_box.swt_widget.getText).to eq('Hello')
      expect(@message_box.swt_widget.getMessage).to eq('Hello, this is a greeting!')
    end    

    it 'renders a message box taking a shell as an argument and a style' do
      @target = shell
      @message_box = message_box(@target, :icon_error, :ok, :cancel) {
        text 'Hello'
        message 'Hello, this is a greeting!'
      }
      
      expect(@message_box).to be_a(Glimmer::SWT::MessageBoxProxy)
      expect(@message_box.swt_widget).to be_a(MessageBox)
      expect(@message_box.swt_widget.getText).to eq('Hello')
      expect(@message_box.swt_widget.getMessage).to eq('Hello, this is a greeting!')
      expect(@message_box.swt_widget).to have_style(:icon_error)
      expect(@message_box.swt_widget).to have_style(:ok)
      expect(@message_box.swt_widget).to have_style(:cancel)
    end    
  end
end
