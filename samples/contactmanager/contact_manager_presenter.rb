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

require File.dirname(__FILE__) + "/contact_repository"

class ContactManagerPresenter
  attr_accessor :results
  @@contact_attributes = [:first_name, :last_name, :email]
  @@contact_attributes.each {|attribute_name| attr_accessor attribute_name}
  
  def initialize
    @contact_repository = ContactRepository.new
    @results = []
  end
  
  def find
    filter_map = Hash.new
    @@contact_attributes.each do |attribute_name| 
      filter_map[attribute_name] = self.send(attribute_name) if self.send(attribute_name)
    end
    self.results=@contact_repository.find(filter_map)
  end
end