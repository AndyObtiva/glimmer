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

require 'glimmer/data_binding/observable'

module Glimmer
  module DataBinding
    # Represents a Hash-like object with attributes writable via :[]= store method like Hash, Struct, and OpenStruct
    # Expects including class to have the following methods:
    # - key_observer_list
    # - all_key_observer_list
    # - unregister_dependent_observer
    # - ensure_array_object_observer
    module ObservableHashable
      include Observable
      
      OBSERVED_STORE_METHOD = lambda do |options|
        lambda do |key, value|
          if key_observer_list(key).empty?
            if all_key_observer_list.empty?
              self.send('__original__store', key, value)
            else
              old_value = self[key]
              unregister_dependent_observers(nil, old_value) # remove dependent observers previously installed in ensure_array_object_observer
              self.send('__original__store', key, value)
              notify_observers(key)
              ensure_array_object_observer(nil, value, old_value, options)
            end
          else
            old_value = self[key]
            unregister_dependent_observers(key, old_value) # remove dependent observers previously installed in ensure_array_object_observer
            self.send('__original__store', key, value)
            notify_observers(key)
            ensure_array_object_observer(key, value, old_value, options)
          end
        end
      end

      def add_key_writer_observer(key = nil, options)
        ensure_array_object_observer(key, self[key], nil, options)
        begin
          method('__original__store')
        rescue
          define_singleton_method('__original__store', store_method)
          define_singleton_method('[]=', &OBSERVED_STORE_METHOD.call(options))
        end
      rescue => e
        #ignore writing if no key writer exists
        Glimmer::Config.logger.debug {"No need to observe store method: '[]='\n#{e.message}\n#{e.backtrace.join("\n")}"}
      end
      
      def store_method
        self.class.instance_method('[]=') rescue self.method('[]=')
      end
    end
  end
end
