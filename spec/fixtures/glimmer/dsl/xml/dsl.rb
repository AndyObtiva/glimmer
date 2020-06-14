Dir.glob(File.join(File.expand_path('..', __FILE__), '*')).each {|f| require f}

module Glimmer
  module DSL
    module XML
      Engine.add_dynamic_expressions(XML, 'xml_dynamic')
    end
  end
end 
