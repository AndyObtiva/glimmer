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

require File.dirname(__FILE__) + "/glimmer"

class Array
  include Glimmer
  
  alias original_compare <=>
  
  def <=>(other)
    if (self[0].class.name == "RWidget")
      add_contents(self[0]) {
        if (other.size == 2)
          eval("#{self[1]} bind (other[0], other[1])")
        elsif (other.size == 3)
          eval("#{self[1]} bind (other[0], other[1], other[2])")
        end
      }
    else
      original_compare(other)
    end
  end
end
