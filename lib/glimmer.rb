# Glimmer - a JRuby DSL that enables easy and efficient authoring of user
# interfaces using the robust platform-independent Eclipse SWT library. Glimmer
# comes with built-in data-binding support to greatly facilitate synchronizing
# UI with domain models.

require "rubygems"
require "facets"
require "logger"
require "java"
require "puts_debuggerer"
require File.dirname(__FILE__) + "/string"
require File.dirname(__FILE__) + "/symbol"
require File.dirname(__FILE__) + "/parent"

module Glimmer

  include_package 'org.eclipse.swt'

  @@parent_stack = []
  @@logger = Logger.new(STDOUT).tap {|logger| logger.level = Logger::WARN}
  PutsDebuggerer.print_engine = lambda {|content| @@logger.debug(content)} #TODO use everywhere in place of logger

  def self.logger
    @@logger
  end

  def self.method_missing(method_symbol, *args, &block)
    Glimmer.logger.debug "method: " + method_symbol.to_s + " and args: " + args.to_s
    command_handler_chain = CommandHandlerChainFactory.chain
    return_value = command_handler_chain.handle(@@parent_stack.last, method_symbol, *args, &block)
    add_contents(return_value, &block)
    return return_value
  end

  def self.add_contents(parent, &block)
    @@parent_stack.push(parent) if parent.is_a?(Parent)
    @@parent_stack.last.process_block(block) if block and @@parent_stack.last
    @@parent_stack.pop if parent.is_a?(Parent)
  end

  def self.dsl(dsl)
    CommandHandlerChainFactory.select_dsl(dsl)
  end

  #added for convenience

  def method_missing(method_symbol, *args, &block)
    Glimmer.method_missing(method_symbol, *args, &block)
  end

  def add_contents(parent, &block)
    Glimmer.add_contents(parent, &block)
  end

  def dsl(dsl)
    CommandHandlerChainFactory.select_dsl(dsl)
  end
end

# Command handlers may rely on Glimmer, so this is put here to avoid an infinite loop.
require File.dirname(__FILE__) + "/xml_command_handlers"
require File.dirname(__FILE__) + "/command_handlers"
