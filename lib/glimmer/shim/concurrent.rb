require 'set'

# Accommadate libraries that do not need or support concurrent-ruby (e.g. Glimmer DSL for Opal)
if !Object.constants.include?(:Concurrent)
  module Concurrent
    Array = ::Array
    Hash = ::Hash
    Set = ::Set
  end
end
