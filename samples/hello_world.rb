################################################################################
# Copyright (c) 2008 Annas Al Maleh.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#    Annas Al Maleh - initial API and implementation
################################################################################ 

require "java"
require File.dirname(__FILE__) + "/../lib/swt"

class HelloWorld
	include_package 'org.eclipse.swt'
	include_package 'org.eclipse.swt.layout'
	
	include Glimmer

	def launch
		@shell = shell {
			text "SWT"
			composite {
				label { 
					text "Hello World!" 
				}
			}
		}
    @shell.open
	end
end

HelloWorld.new.launch
