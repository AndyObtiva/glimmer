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

class Contact
  attr_accessor :first_name, :last_name, :email
  
  def initialize(attribute_map)
    @first_name = attribute_map[:first_name]
    @last_name = attribute_map[:last_name]
    @email = attribute_map[:email]
  end
end