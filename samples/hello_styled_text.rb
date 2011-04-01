require File.dirname(__FILE__) + "/../lib/glimmer"
class HelloStyledText
  include Glimmer
  include_package "org.eclipse.swt.graphics"
  include_package "org.eclipse.swt.custom"
  include_package "org.eclipse.swt"
  def launch
    @shell = shell {|s|
      composite {
        styled_text(:multi){
          range = StyleRange.new
          range.start = 0
          range.length = 5
          range.fontStyle = SWT::BOLD
          range.foreground = Color.new(s.parent, 255 ,0 ,0)
          text "Hello World!"
          style_range range
        }
      }
    }.open
  end
end

HelloStyledText.new.launch
