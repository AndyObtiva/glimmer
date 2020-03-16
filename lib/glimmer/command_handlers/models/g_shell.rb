require_relative 'g_widget'
require_relative 'g_display'

module Glimmer
  class GShell < GWidget
    include_package 'org.eclipse.swt.layout'
    include_package 'org.eclipse.swt.widgets'

    attr_reader :display

    def initialize(display = GDisplay.instance.display)
      @display = display
      @widget = Shell.new(@display)
      @widget.setLayout(FillLayout.new)
    end

    def open
      @widget.pack
      @widget.open
      until @widget.isDisposed
        @display.sleep unless @display.readAndDispatch
      end
      @display.dispose
    end

  end
end
