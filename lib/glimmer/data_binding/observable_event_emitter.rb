# Copyright (c) 2007-2024 Andy Maleh
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
    module ObservableEventEmitter
      include Observable
    
      # Pass observer + event to listen to or nothing to listen to all events
      def add_observer(observer, event = nil)
        event = normalize_event(event)
        if event.nil?
          observers_for_all_events << observer
        else
          observers_for(event) << observer
        end
      end

      def remove_observer(observer, event = nil)
        event = normalize_event(event)
        if event.nil?
          if has_observer_for_all_events?(observer)
            observers_for_all_events.delete(observer)
            observer.unobserve(self)
          end
        else
          if has_observer_for_event?(observer, event)
            observers_for(event).delete(observer)
            observer.unobserve(self, event)
          end
        end
      end
      
      def notify_observers(event, value = nil)
        event = normalize_event(event)
        observers_for(event).each do |observer|
          observer.call(value)
        end
        observers_for_all_events.each do |observer|
          observer.call(value, event)
        end
      end
      
      def observers
        @observers ||= Concurrent::Hash.new
      end
      
      def observers_for(event)
        observers[event] ||= Concurrent::Array.new
      end
      
      def observers_for_all_events
        @observers_for_all_events ||= Concurrent::Array.new
      end
      
      def has_observer_for_event?(observer, event)
        event = normalize_event(event)
        observers_for(event).include?(observer)
      end
      
      def has_observer_for_all_events?(observer)
        event = normalize_event(event)
        observers_for_all_events.include?(observer)
      end
      
      private
      
      def normalize_event(event)
        event.to_sym unless event.nil?
      end
    end
  end
end
