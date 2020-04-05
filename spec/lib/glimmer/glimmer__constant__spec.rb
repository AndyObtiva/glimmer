require "spec_helper"

java_import 'org.eclipse.swt.widgets.Composite'

module Glimmer
  describe "Glimmer Constant" do
    include Glimmer

    after do
      @target.dispose if @target
    end

    it "test shell with default layout and composite" do
      @target = shell {
        composite(:border, :no_focus) {
        }
      }

      expect(@target.widget.children.size).to eq(1)
      expect(@target.widget.children[0]).to be_instance_of(Composite)
      composite_widget = @target.widget.children[0]
      expect(composite_widget).to have_style(:no_focus)
      expect(composite_widget).to have_style(:border)
    end
  end
end
