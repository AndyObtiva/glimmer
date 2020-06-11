require 'opal'
# require 'opal-jquery'
require 'browser'

class String
  def underscore
    gsub(/[A-Z]/) {|m| "_#{m.downcase}"}.sub(/^_/, '')
  end
  
  def camelcase(option=nil)
    new_string = split("_").map {|word| word[0].upcase + word[1..-1]}.join
    if option == :upper
      new_string
    else
      new_string.sub(/^./) {|c| c.downcase}
    end
  end
  
#   def titlecase
#     #TODO
#   end
end

require 'glimmer/dsl/engine'
# Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}
require 'glimmer/dsl/opal/shell_expression'
require 'glimmer/dsl/opal/label_expression'
require 'glimmer/dsl/opal/property_expression'

module Glimmer
  module DSL
    module Opal
      Engine.add_dynamic_expressions(
       Opal,
       %w[
         property
       ]
      )
    end
  end
end
