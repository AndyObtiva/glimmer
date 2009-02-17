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
# Glimmer - a JRuby DSL that enables easy and efficient authoring of user 
# interfaces using the robust platform-independent Eclipse SWT library. Glimmer 
# comes with built-in data-binding support to greatly facilitate synchronizing 
# UI with domain models.

require "rubygems"
require "facets"
require "java"
require File.dirname(__FILE__) + "/parent"

module Glimmer
  
  include_package 'org.eclipse.swt'
  
  @@parent_stack = []

  def self.method_missing(method_symbol, *args, &block)
    puts "method: " + method_symbol.to_s + " and args: " + args.to_s
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

  #added for convenience
  
  def method_missing(method_symbol, *args, &block)
    Glimmer.method_missing(method_symbol, *args, &block)
  end

  def add_contents(parent, &block)
    Glimmer.add_contents(parent, &block)
  end
end

# Command handlers may rely on Glimmer, so this is put here to avoid an infinite loop.
#require File.dirname(__FILE__) + "/command_handlers"
