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

module Glimmer
  module DataBinding
    class Shine
      include Glimmer
      
      def initialize(parent, parent_attribute)
        @parent = parent
        @parent_attribute = parent_attribute
      end
      
      def <=>(other)
        if other.is_a?(Array)
          args_clone = other.clone
          @parent.content {
            send(@parent_attribute, bind(*args_clone))
          }
        end
      end
    
      def <=(other)
        if other.is_a?(Array)
          args_clone = other.clone
          if args_clone.last.is_a?(Hash)
            args_clone.last[:read_only] = true
          else
            args_clone << {read_only: true}
          end
          @parent.content {
            send(@parent_attribute, bind(*args_clone))
          }
        end
      end
    end
  end
end
