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

require 'glimmer/dsl/static_expression'
require 'glimmer/data_binding/model_binding'

module Glimmer
  module DSL
    # Responsible for setting up the return value of the bind keyword (command symbol)
    # as a ModelBinding. It is to be used as the argument of another data-binding expression.
    module BindExpression
      def can_interpret?(parent, keyword, *args, &block)
        (
          keyword == 'bind' and
            (
              (
                (args.size == 2) and
                  textual?(args[1])
              ) ||
                (
                  (args.size == 3) and
                    textual?(args[1]) and
                    (args[2].is_a?(Hash))
                )
            )
        )
      end

      def interpret(parent, keyword, *args, &block)
        binding_options = args[2] || {}
        binding_options[:on_read] = binding_options.delete(:on_read) || binding_options.delete('on_read') || block
        DataBinding::ModelBinding.new(args[0], args[1].to_s, binding_options)
      end
    end
  end
end
