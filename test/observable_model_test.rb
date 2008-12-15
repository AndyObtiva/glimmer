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

require File.dirname(__FILE__) + "/test_helper"
require File.dirname(__FILE__) + "/../lib/command_handlers/models/observable_model"

require "test/unit"
class ObservableModelTest < Test::Unit::TestCase
  class Person 
    attr_accessor :name
  end

  def test_observe_model
    person = Person.new
    person.name = "Marty"
    assert_equal "Marty", person.name
    person.extend ObservableModel
    person.add_observer(:name, self)
    person.name = "Julia"
    assert_equal "Julia", @observed_name
    assert_equal "Julia", person.name
  end
  
  def update(name)
    @observed_name = name
  end
end