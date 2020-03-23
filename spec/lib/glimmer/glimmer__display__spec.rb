require "spec_helper"

module Glimmer
  describe "Glimmer Display" do
    include Glimmer

    before do
      @rspec_display_method = method(:display)
      self.class.send(:undef_method, :display)
      dsl :swt
    end

    after do
      @target.dispose if @target
      @target2.dispose if @target2
      self.class.send(:define_method, :display, @rspec_display_method)
    end

    it "tests display" do
      @target = display

      expect(@target).to be_a(Glimmer::SWT::GDisplay)
      expect(@target.display).to be_a(Display)
      expect(@target.display.isDisposed).to be_falsey

      @target2 = display
      expect(@target2.display).to eq(@target.display)

      @target2.dispose
      @target2 = display
      expect(@target2.display).to_not eq(@target.display)
    end
  end
end
