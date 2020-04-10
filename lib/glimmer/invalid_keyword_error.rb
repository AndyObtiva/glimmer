module Glimmer
  # Represents Glimmer errors that occur due to invalid use of Glimmer
  # without handing control flow back to original method_missing
  class InvalidKeywordError < RuntimeError
  end
end
