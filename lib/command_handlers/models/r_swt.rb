class RSwt
  class << self
    def for(*symbols)
      symbols.reduce(0) do |output, symbol|
        swt_constant_symbol = symbol.to_s.upcase.to_sym
        begin
          swt_constant = org.eclipse.swt.SWT.const_get(swt_constant_symbol)
        rescue
          swt_constant_symbol = org.eclipse.swt.SWT.constants.find {|c| c.to_s.upcase == swt_constant_symbol}
          swt_constant = org.eclipse.swt.SWT.const_get(swt_constant_symbol)
        end
        output | swt_constant
      end
    end
  end
end
