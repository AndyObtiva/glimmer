# Glimmer - a JRuby DSL that enables easy and efficient authoring of user
# interfaces using the robust platform-independent Eclipse SWT library. Glimmer
# comes with built-in data-binding support to greatly facilitate synchronizing
# UI with domain models.

require "rubygems"
require "facets"
require "super_module"
require "logger"
require "java"
require "nested_inherited_jruby_include_package"
require_relative "glimmer/parent"
require_relative "glimmer/swt_packages" #TODO move into SWT namespace
require_relative "glimmer/swt/custom_widget"
require_relative 'glimmer/swt/video' # TODO offload to a custom widget directory

module Glimmer
  REGEX_METHODS_EXCLUDED = /^(to_|\[)/
   #TODO make it configurable to include or not include
  include SwtPackages

  class << self
    def included(klass)
      klass.include SwtPackages
    end

    def logger
      unless defined? @@logger
        @@logger = Logger.new(STDOUT).tap {|logger| logger.level = Logger::WARN}
      end
      @@logger
    end

    def parent_stack
      unless defined? @@parent_stack
        @@parent_stack = []
      end
      @@parent_stack
    end

    def current_parent
      parent_stack.last
    end

    alias method_missing_without_glimmer method_missing
    def method_missing(method_symbol, *args, &block)
      # This if statement speeds up Glimmer in girb or whenever directly including on main object
      if method_symbol.to_s.match(REGEX_METHODS_EXCLUDED)
        return method_missing_without_glimmer(method_symbol, *args, &block)
      end
      begin
        Glimmer.logger.debug "method: " + method_symbol.to_s + " and args: " + args.to_s
        command_handler_chain = CommandHandlerChainFactory.chain
        return_value = command_handler_chain.handle(current_parent, method_symbol, *args, &block)
        add_content(return_value, &block)
        return return_value
      end
    end

    def add_content(parent, &block)
      parent_stack.push(parent) if parent.is_a?(Parent)
      current_parent.process_block(block) if block and current_parent
      parent_stack.pop if parent.is_a?(Parent)
    end
  end

  def method_missing(method_symbol, *args, &block)
    Glimmer.method_missing(method_symbol, *args, &block)
  end

  def add_content(parent, &block)
    Glimmer.add_content(parent, &block)
  end
end

require File.dirname(__FILE__) + "/glimmer/command_handlers"
