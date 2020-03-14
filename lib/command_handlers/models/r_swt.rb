class RSwt
  class << self
    # Gets SWT constants as if calling SWT::CONSTANT where constant is
    # passed in as a lower case symbol
    def [](*symbols)
      symbols.compact.reduce(0) { |output, symbol| output | constant(symbol) }
    end

    def constant(symbol)
      return symbol if symbol.is_a?(Integer)
      swt_constant_symbol = symbol.to_s.upcase.to_sym
      org.eclipse.swt.SWT.const_get(swt_constant_symbol)
    rescue
      swt_constant_symbol = org.eclipse.swt.SWT.constants.find {|c| c.to_s.upcase == swt_constant_symbol.to_s}
      org.eclipse.swt.SWT.const_get(swt_constant_symbol)
    end
  end
end
