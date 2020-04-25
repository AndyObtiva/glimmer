require 'glimmer/error'

module Glimmer
  module SWT # TODO Consider making this the class below to ease calling it
    # Proxy for org.eclipse.swt.SWT
    #
    # Follows the Proxy Design Pattern
    class SWTProxy
      class << self
        java_import 'org.eclipse.swt.SWT'

        ERROR_INVALID_STYLE = " is an invalid SWT style! Please choose a style from org.eclipse.swt.SWT class constants."
        REGEX_SYMBOL_NEGATIVITY = /^([^!]+)(!)?$/

        # Gets SWT constants as if calling SWT::CONSTANT where constant is
        # passed in as a lower case symbol
        def [](*symbols)
          symbols = symbols.first if symbols.size == 1 && symbols.first.is_a?(Array)
          result = symbols.compact.map do |symbol|
            constant(symbol).tap do |constant_value|
              raise Error, symbol.to_s + ERROR_INVALID_STYLE unless constant_value.is_a?(Integer)
            end
          end.reduce do |output, constant_value|
            if constant_value < 0
              output & constant_value
            else
              output | constant_value
            end
          end
          result.nil? ? SWT::NONE : result
        end

        # Returns SWT style integer value for passed in symbol or allows
        # passed in object to pass through (e.g. Integer). This makes is convenient
        # to use symbols or actual SWT style integers in Glimmer
        # Does not raise error for invalid values. Just lets them pass as is.
        # (look into [] operator if you want an error raised on invalid values)
        def constant(symbol)
          return symbol unless symbol.is_a?(Symbol) || symbol.is_a?(String)
          symbol_string, negative = extract_symbol_string_negativity(symbol)
          swt_constant_symbol = symbol_string.downcase == symbol_string ? symbol_string.upcase.to_sym : symbol_string.to_sym
          bit_value = SWT.const_get(swt_constant_symbol)
          negative ? ~bit_value : bit_value
        rescue => e
          begin
#             Glimmer.logger&.debug(e.full_message)
            alternative_swt_constant_symbol = SWT.constants.find {|c| c.to_s.upcase == swt_constant_symbol.to_s.upcase}
            bit_value = SWT.const_get(alternative_swt_constant_symbol)
            negative ? ~bit_value : bit_value
          rescue => e
#             Glimmer.logger&.debug(e.full_message)
            bit_value = Glimmer::SWT::SWTProxy::EXTRA_STYLES[swt_constant_symbol]
            if bit_value
              negative ? ~bit_value : bit_value
            else
              symbol
            end
          end
        end

        def extract_symbol_string_negativity(symbol)
          if symbol.is_a?(Symbol) || symbol.is_a?(String)
            symbol_negativity_match = symbol.to_s.match(REGEX_SYMBOL_NEGATIVITY)
            symbol = symbol_negativity_match[1]
            negative = !!symbol_negativity_match[2]
            [symbol, negative]
          else
            negative = symbol < 0
            [symbol, negative]
          end
         end

        def negative?(symbol)
          extract_symbol_string_negativity(symbol)[1]
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

        def include?(swt_constant, *symbols)
          swt_constant & self[symbols] == self[symbols]
        end
      end

      EXTRA_STYLES = {
        NO_RESIZE: self[:shell_trim, :resize!, :max!]
      }
    end
  end
end
