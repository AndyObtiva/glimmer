# Copyright (c) 2007-2022 Andy Maleh
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

require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/model_binding'

module Glimmer
  module DSL
    module ObserveExpression
      REGEX_NESTED_OR_INDEXED_PROPERTY = /([^\[]+)(\[[^\]]+\])?/

      def can_interpret?(parent, keyword, *args, &block)
        keyword == 'observe' and
          block_given? and
          (args.size >= 1) and
          (args[1].nil? || args[1].is_a?(Hash) || textual?(args[1]))
      end

      def interpret(parent, keyword, *args, &block)
        observer = DataBinding::Observer.proc(&block)
        if args[1].to_s.match(REGEX_NESTED_OR_INDEXED_PROPERTY)
          observer_registration = observer.observe(DataBinding::ModelBinding.new(*args))
        else
          observer_registration = observer.observe(*args)
        end
        observer_registration
      end
    end
  end
end
