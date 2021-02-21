# Copyright (c) 2007-2021 Andy Maleh
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

require 'glimmer/error'

module Glimmer
  module DSL
    # Represents a Glimmer DSL expression (e.g. label(:center) { ... })
    #
    # An expression object can interpret a keyword, args, and a block into a UI object
    #
    # Expressions subclasses follow the convention of using `and` and `or`
    # english versino of Ruby's boolean operations. This allows easy DSL-like
    # readability of the rules, and easy printout with puts_debuggerer when troubleshooting.
    class Expression
      class << self
        def dsl
          @dsl ||= name.split(/::/)[-2].downcase.to_sym
        end
      end

      # Checks if it can interpret parameters (subclass must override)
      def can_interpret?(parent, keyword, *args, &block)
        raise Error, "#can_interpret? must be implemented by an Expression subclass"
      end

      # Interprets parameters (subclass must override)
      def interpret(parent, keyword, *args, &block)
        raise Error, "#interpret must be implemented by an Expression subclass"
      end

      # Adds block content to specified parent UI object (Optional)
      #
      # Only expressions that receive a content block should implement
      def add_content(parent, keyword, *args, &block)
        # No Op by default
      end

      # Checks if object is a Symbol or a String
      def textual?(object)
        object.is_a?(Symbol) or object.is_a?(String)
      end
    end
  end
end
