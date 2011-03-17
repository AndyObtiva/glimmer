class String
  def swt_widget
    org.eclipse.swt.widgets.__send__(camelcase(:upper))
  end
  def swt_constant
    org.eclipse.swt.__send__("SWT").class_eval(upcase)
  end
end