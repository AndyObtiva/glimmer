require "java"
require File.dirname(__FILE__) + "/../lib/glimmer"

class HelloWorld
	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.layout'
	
	include Glimmer

	def launch
		@shell = shell {
			text "SWT"
      label {
        text "Hello World!"
      }
		}
    @shell.open
	end
end

HelloWorld.new.launch
