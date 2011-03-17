require File.dirname(__FILE__) + "/string"

class Symbol
  def swt_widget
    to_s.swt_widget
  end
  def swt_constant
    to_s.swt_constant
  end
end