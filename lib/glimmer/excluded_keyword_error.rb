module Glimmer
  # Represents Glimmer errors that occur due to excluded keywords passing through method_missing
  class ExcludedKeywordError < RuntimeError
  end
end
