module Glimmer
  class GSWT
    class << self
      java_import 'org.eclipse.swt.SWT'

      # Gets SWT constants as if calling SWT::CONSTANT where constant is
      # passed in as a lower case symbol
      def [](*symbols)
        symbols.compact.reduce(0) { |output, symbol| output | constant(symbol) }
      end

      def constant(symbol)
        return symbol unless symbol.is_a?(Symbol) || symbol.is_a?(String)
        swt_constant_symbol = symbol.to_s.upcase.to_sym
        SWT.const_get(swt_constant_symbol)
      rescue
        swt_constant_symbol = SWT.constants.find {|c| c.to_s.upcase == swt_constant_symbol.to_s}
        SWT.const_get(swt_constant_symbol)
      end

      def has_constant?(symbol)
        return false unless symbol.is_a?(Symbol) || symbol.is_a?(String)
        !!constant(symbol)
      rescue
        false
      end
    end
  end
end
