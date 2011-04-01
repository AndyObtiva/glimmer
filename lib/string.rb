class String
  def swt_widget
    RWidget.swt_widget(camelcase(:upper))
  end

  def swt_constant
    org.eclipse.swt.__send__("SWT").class_eval(upcase)
  end
end
