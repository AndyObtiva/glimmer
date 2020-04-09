module Glimmer
  module Util
    class ProcTracker < DelegateClass(Proc)
      def initialize(proc)
        super(proc)
      end
      def call(*args)
        __getobj__.call(*args)
        @called = true
      end
      def called?
        !!@called
      end
    end
  end
end
