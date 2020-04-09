module Glimmer
  module DataBinding
    module ObservableWidget
      # TODO see if it is worth it to eliminate duplication of method_missing
      # from GWidget using a module

      def method_missing(method, *args, &block)
        method_name = method.to_s
        if can_handle_observation_request?(method_name)
          handle_observation_request(method_name, &block)
        else
          super
        end
      end
    end
  end
end
