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

require File.dirname(__FILE__) + "/contact"

class ContactRepository
  def initialize
    @contacts = [
      Contact.new(:first_name => "Anne", :last_name => "Sweeney", :email => "anne@sweeny.com"),
      Contact.new(:first_name => "Beatrice", :last_name => "Jung", :email => "beatrice@jung.com"),
      Contact.new(:first_name => "Frank", :last_name => "Deelio", :email => "frank@deelio.com"),
      Contact.new(:first_name => "franky", :last_name => "miller", :email => "frank@miller.com"),
    ]
  end
  
  def find(attribute_filter_map)
    @contacts.find_all do |contact|
      match = true
      attribute_filter_map.keys.each do |attribute_name|
        contact_value = contact.send(attribute_name).downcase
        filter_value = attribute_filter_map[attribute_name].downcase
        match = false unless contact_value.match(filter_value)
      end
      match
    end
  end
end