module Glimmer
  # edit to add more packages and support custom widgets
  module SwtPackages
    def self.included(klass)
      klass.class_eval do
        include_package 'org.eclipse.swt'
        include_package 'org.eclipse.swt.widgets'
        include_package 'org.eclipse.swt.layout'
        include_package 'org.eclipse.swt.graphics'
        include_package 'org.eclipse.swt.browser'
      end
    end
  end
end
