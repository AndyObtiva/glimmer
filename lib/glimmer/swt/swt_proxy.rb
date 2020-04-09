module Glimmer
  module SWT # TODO Consider making this the class below to ease calling it
    # Proxy for org.eclipse.swt.SWT
    #
    # Follows the Proxy Design Pattern
    class SWTProxy
      class << self
        java_import 'org.eclipse.swt.SWT'

        ERROR_INVALID_STYLE = " is an invalid SWT style! Please choose a style from org.eclipse.swt.SWT class constants."

        # Gets SWT constants as if calling SWT::CONSTANT where constant is
        # passed in as a lower case symbol
        def [](*symbols)
          symbols = symbols.first if symbols.size == 1 && symbols.first.is_a?(Array)
          symbols.compact.reduce(0) do |output, symbol|
            constant_value = constant(symbol)
            if constant_value.is_a?(Integer)
              output | constant(symbol)
            else
              raise symbol.to_s + ERROR_INVALID_STYLE
            end
          end
        end

        # Returns SWT style integer value for passed in symbol or allows
        # passed in object to pass through (e.g. Integer). This makes is convenient
        # to use symbols or actual SWT style integers in Glimmer
        # Does not raise error for invalid values. Just lets them pass as is.
        # (look into [] operator if you want an error raised on invalid values)
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
        NO_RESIZE: SWTProxy[:shell_trim] & (~SWTProxy[:resize]) & (~SWTProxy[:max])
      }
    end
  end
end
