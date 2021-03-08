# Just a fixture for testing hooks by keeping them in context

class Context
  class << self
    def around_stack
      @around_stack ||= []
    end
  end
end
