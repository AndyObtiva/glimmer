require "spec_helper"

describe Glimmer do
  after do
    Glimmer.import_swt_packages = true
    %w[
      SomeApp
      AnotherApp
      SomeWidget
      AnotherWidget
      SomeShell
      AnotherShell
    ].each do |constant|
      Object.send(:remove_const, constant) if Object.const_defined?(constant)
    end
  end

  #TODO clean up SOmeApp and AnotherApp
  it 'disables automatic include of SWT packages in Glimmer apps' do
    class SomeApp
      include Glimmer
    end

    expect(SomeApp::Label).to eq(org.eclipse.swt.widgets.Label)

    Glimmer.import_swt_packages = false

    class AnotherApp
      include Glimmer
    end

    expect {AnotherApp::Label}.to raise_error(NameError)
  end

  it 'disables automatic include of SWT packages in Glimmer custom widgets' do
    class SomeWidget
      include Glimmer::UI::CustomWidget
    end

    expect(SomeWidget::Label).to eq(org.eclipse.swt.widgets.Label)

    Glimmer.import_swt_packages = false

    class AnotherWidget
      include Glimmer::UI::CustomWidget
    end

    expect {AnotherWidget::Label}.to raise_error(NameError)
  end

  it 'disables automatic include of SWT packages in Glimmer custom shells' do
    class SomeShell
      include Glimmer::UI::CustomShell
    end

    expect(SomeShell::Label).to eq(org.eclipse.swt.widgets.Label)

    Glimmer.import_swt_packages = false

    class AnotherShell
      include Glimmer::UI::CustomShell
    end

    expect {AnotherShell::Label}.to raise_error(NameError)
  end

end
