# Copyright (c) 2007-2025 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'facets/string/underscore'

require 'glimmer/error'
require 'glimmer/dsl/engine'
require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    # Represents a StaticExpression for expressions where
    # the keyword does not vary dynamically. These static keywords are then
    # predefined as methods in Glimmer instead of needing method_missing
    #
    # StaticExpression subclasses may optionally implement `#can_interpret?`
    # (not needed if it only checks for keyword)
    #
    # StaticExpression subclasses must define `#interpret`.
    #
    # The direct parent namespace of a StaticExpression subclass must match the DSL name (case-insensitive)
    # (e.g. Glimmer::DSL::SWT::WidgetExpression has a DSL of :swt)
    class StaticExpression < Expression
      class << self
        def inherited(base)
          Glimmer::DSL::Engine.add_static_expression(base.new)
          super
        end
        
        def keyword
          @keyword ||= name.split(/::/).last.sub(/Expression$/, '').underscore
        end
        
        def downcased(value)
          @downcased = value
          Glimmer::DSL::Engine.add_downcased_static_expression(new) if @downcased
        end
        alias downcase downcased
        
        def downcased?
          # default is true when no attributes are set
          @downcased.nil? && @upcased.nil? && @capitalized.nil? ? true : @downcased
        end
        alias downcase? downcased?
        
        def upcased(value)
          @upcased = value
          Glimmer::DSL::Engine.add_upcased_static_expression(new) if @upcased
        end
        alias upcase upcased
        
        def upcased?
          @upcased
        end
        alias upcase? upcased?
        
        def capitalized(value)
          @capitalized = value
          Glimmer::DSL::Engine.add_capitalized_static_expression(new) if @capitalized
        end
        alias capitalize capitalized
        alias capital capitalized
        
        def capitalized?
          @capitalized
        end
        alias capitalize? capitalized?
        alias capital? capitalized?
        
        def case_insensitive(value)
          if value
            self.downcased(true)
            self.upcased(true)
            self.capitalized(true)
          else
            self.downcased(true)
            self.upcased(false)
            self.capitalized(false)
          end
        end
        
        def case_insensitive?
          downcased? && upcased? && capitalized?
        end
      end

      # Subclasses may optionally implement, but by default it only ensures that
      # the keyword matches lower case static expression class name minus `Expression`
      def can_interpret?(parent, keyword, *args, &block)
        result = false
        result ||= keyword.downcase == keyword if self.class.downcased?
        result ||= keyword.upcase == keyword if self.class.upcased?
        result ||= keyword.capitalize == keyword if self.class.capitalized?
        result
      end
    end
  end
end
