# Copyright (c) 2007-2022 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'logger'
require 'set'
require 'array_include_methods'

$LOAD_PATH.unshift(File.expand_path('..', __FILE__))

require 'glimmer/shim/concurrent'
require 'glimmer/config'
require 'glimmer/ext/module'

# Glimmer provides a JRuby Desktop UI DSL + Data-Binding functionality
#
# A desktop UI application class must include Glimmer to gain access to Glimmer DSL
#
# Glimmer DSL static keywords (e.g. rgb, bind, etc..) are available as inherited methods
# Glimmer DSL dynamic keywords (e.g. label, combo, etc...) are available via method_missing
module Glimmer
  #TODO make it configurable to include or not include perhaps reverting to using included
  
  # TODO add loop detection support to avoid infinite loops (perhaps breaks after 3 repetitions and provides an option to allow it if intentional)
  class << self
    attr_accessor :loop_last_data
    
    def loop_reset!(including_loop_last_data = false)
      @loop_last_data = nil if including_loop_last_data
      @loop = 1
    end
    
    def loop
      @loop ||= loop_reset!
    end
    
    def loop_increment!
      @loop = loop + 1
    end
  end

  def method_missing(method_symbol, *args, &block)
    # This if statement speeds up Glimmer in girb or whenever directly including on main object
    is_excluded = Config.excluded_keyword_checkers.any? do |checker|
      instance_exec(method_symbol, *args, &checker)
    end
    if is_excluded
      Glimmer::Config.logger.debug "Glimmer excluded keyword: #{method_symbol}" if Glimmer::Config.log_excluded_keywords?
      super(method_symbol, *args, &block)
    else
      new_loop_data = [method_symbol, args, block]
      if new_loop_data == Glimmer.loop_last_data
        Glimmer.loop_increment!
        raise "Glimmer looped #{Config.loop_max_count} times with keyword '#{new_loop_data[0]}'! Check code for errors." if Glimmer.loop == Config.loop_max_count
      else
        Glimmer.loop_reset!
      end
      Glimmer.loop_last_data = new_loop_data
      Glimmer::Config.logger.info {">"*80}
      Glimmer::Config.logger.info {"Interpreting keyword: #{method_symbol}"}
      Glimmer::DSL::Engine.interpret(method_symbol, *args, &block)
    end
  rescue InvalidKeywordError => e
    Glimmer::Config.logger.error {"Encountered an invalid keyword at this object: #{self}"}
    Glimmer::Config.logger.error {e.full_message}
    super(method_symbol, *args, &block)
  end
end

require 'glimmer/error'
require 'glimmer/invalid_keyword_error'
require 'glimmer/dsl/engine'
