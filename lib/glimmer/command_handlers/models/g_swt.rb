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
        symbol_string = symbol.to_s
        swt_constant_symbol = symbol_string.downcase == symbol_string ? symbol_string.upcase.to_sym : symbol_string.to_sym
        SWT.const_get(swt_constant_symbol)
      rescue
        begin
          alternative_swt_constant_symbol = SWT.constants.find {|c| c.to_s.upcase == swt_constant_symbol.to_s.upcase}
          SWT.const_get(alternative_swt_constant_symbol)
        rescue
          EXTRA_STYLES[swt_constant_symbol] || symbol
        end
      end

      def has_constant?(symbol)
        return false unless symbol.is_a?(Symbol) || symbol.is_a?(String)
        constant(symbol).is_a?(Integer)
      end

      def constantify_args(args)
        args.map {|arg| constant(arg)}
      end

      # Deconstructs a style integer into symbols
      # Useful for debugging
      def deconstruct(integer)
        SWT.constants.reduce([]) do |found, c|
          constant_value = SWT.const_get(c) rescue -1
          is_found = constant_value.is_a?(Integer) && (constant_value & style) == constant_value
          is_found ? found += [c] : found
        end
      end
    end
    
    EXTRA_STYLES = {
      NO_RESIZE: GSWT[:shell_trim] & (~GSWT[:resize]) & (~GSWT[:max])
    }
  end
end
