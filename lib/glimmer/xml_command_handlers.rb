require File.dirname(__FILE__) + "/command_handler_chain_factory"
require File.dirname(__FILE__) + "/xml/command_handlers/xml_name_space_command_handler"
require File.dirname(__FILE__) + "/xml/command_handlers/xml_text_command_handler"
require File.dirname(__FILE__) + "/xml/command_handlers/xml_tag_command_handler"
require File.dirname(__FILE__) + "/xml/command_handlers/html_command_handler"
require File.dirname(__FILE__) + "/xml/command_handlers/xml_command_handler"

# TODO move into XML namespace
module Glimmer
  # edit to add more command handlers and extend Glimmer
  CommandHandlerChainFactory.def_dsl(:xml,
    XML::CommandHandlers::XmlNameSpaceCommandHandler.new,
    XML::CommandHandlers::XmlTextCommandHandler.new,
    XML::CommandHandlers::XmlTagCommandHandler.new,
    XML::CommandHandlers::HtmlCommandHandler.new,
    XML::CommandHandlers::XmlCommandHandler.new
  )
end
