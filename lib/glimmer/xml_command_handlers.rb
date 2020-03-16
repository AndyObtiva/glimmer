require File.dirname(__FILE__) + "/command_handler_chain_factory"
require File.dirname(__FILE__) + "/xml_command_handlers/xml_name_space_command_handler"
require File.dirname(__FILE__) + "/xml_command_handlers/xml_text_command_handler"
require File.dirname(__FILE__) + "/xml_command_handlers/xml_tag_command_handler"
require File.dirname(__FILE__) + "/xml_command_handlers/html_command_handler"
require File.dirname(__FILE__) + "/xml_command_handlers/xml_command_handler"

# edit to add more command handlers and extend Glimmer
CommandHandlerChainFactory.def_dsl(:xml,
  XmlNameSpaceCommandHandler.new,
  XmlTextCommandHandler.new,
  XmlTagCommandHandler.new,
  HtmlCommandHandler.new,
  XmlCommandHandler.new
)
