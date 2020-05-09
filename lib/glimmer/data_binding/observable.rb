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
 
      # Overriding inspect to avoid printing very long observer hierarchies
      def inspect
        "#<#{self.class.name}:0x#{self.hash.to_s(16)}>"
      end
    end
  end
end
