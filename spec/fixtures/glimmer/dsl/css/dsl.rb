Dir.glob(File.join(File.expand_path('..', __FILE__), '*')).each {|f| require f}

module Glimmer
  module DSL
    module CSS
      Engine.add_dynamic_expressions(CSS, 'css_dynamic', 'property_dynamic')
    end
  end
end 
