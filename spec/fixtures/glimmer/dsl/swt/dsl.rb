Dir.glob(File.join(File.expand_path('..', __FILE__), '*')).each {|f| require f}

module Glimmer
  module DSL
    module SWT
      Engine.add_dynamic_expressions(SWT, ['swt_dynamic'])
    end
  end
end 
