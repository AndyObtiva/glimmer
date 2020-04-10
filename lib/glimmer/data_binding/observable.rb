require 'glimmer/error'

module Glimmer
  module DataBinding
    module Observable
      # TODO rename methods to observe/unobserve
      def add_observer(observer, property_or_properties=nil)
        raise Error, 'Not implemented!'
      end

      def remove_observer(observer, property_or_properties=nil)
        raise Error, 'Not implemented!'
      end
    end
  end
end
