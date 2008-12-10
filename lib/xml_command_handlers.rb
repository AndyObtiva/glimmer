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

require File.dirname(__FILE__) + "/command_handler_chain_factory"
require File.dirname(__FILE__) + "/xml_command_handlers/xml_name_space_command_handler"
require File.dirname(__FILE__) + "/xml_command_handlers/xml_text_command_handler"
require File.dirname(__FILE__) + "/xml_command_handlers/xml_tag_command_handler"
require File.dirname(__FILE__) + "/xml_command_handlers/html_command_handler"
require File.dirname(__FILE__) + "/xml_command_handlers/xml_command_handler"

# edit to add more command handlers and extend Glimmer
CommandHandlerChainFactory.set_command_handlers(
  XmlNameSpaceCommandHandler.new,
  XmlTextCommandHandler.new,
  XmlTagCommandHandler.new,
  HtmlCommandHandler.new,
  XmlCommandHandler.new
)
