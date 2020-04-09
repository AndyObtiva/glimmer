# Glimmer - a JRuby DSL that enables easy and efficient authoring of user
# interfaces using the robust platform-independent Eclipse SWT library. Glimmer
# comes with built-in data-binding support to greatly facilitate synchronizing
# UI with domain models.

require 'facets'
require 'super_module'
require 'logger'
require 'java'
require 'set'
require 'nested_inherited_jruby_include_package'

# Glimmer provides a JRuby Desktop UI DSL + Data-Binding functionality
#
# A desktop UI application class must include Glimmer to gain access to Glimmer DSL
#
# Glimmer DSL static keywords (e.g. rgb, bind, etc..) are available as inherited methods
# Glimmer DSL dynamic keywords (e.g. label, combo, etc...) are available via method_missing
module Glimmer
  #TODO make it configurable to include or not include perhaps reverting to using included
  REGEX_METHODS_EXCLUDED = /^(to_|\[)/

  class << self
    def included(klass)
      if import_swt_packages
        klass.include(SWT::Packages)
      end
    end

    # Tells Glimmer to import SWT packages into including class (default: true)
    def import_swt_packages=(value)
      @@import_swt_packages = !!value
    end

    # Returns whether Glimmer will import SWT packages into including class
    def import_swt_packages
      unless defined? @@import_swt_packages
        @@import_swt_packages = true
      end
      @@import_swt_packages
    end

    # Returns Glimmer logger (standard Ruby logger)
    def logger
      unless defined? @@logger
        @@logger = Logger.new(STDOUT).tap {|logger| logger.level = Logger::WARN}
      end
      @@logger
    end
  end

  alias method_missing_without_glimmer method_missing
  def method_missing(method_symbol, *args, &block)
    # This if statement speeds up Glimmer in girb or whenever directly including on main object
    if method_symbol.to_s.match(REGEX_METHODS_EXCLUDED)
      raise "Glimmer excluded method: #{method_symbol}"
    end
    Glimmer.logger.debug "method: " + method_symbol.to_s + " and args: " + args.to_s
    Glimmer::DSL::Engine.interpret(method_symbol, *args, &block)
  rescue => e
    if !method_symbol.to_s.match(REGEX_METHODS_EXCLUDED)
      Glimmer.logger.error e.message
    end
    Glimmer.logger.debug "#{e.message}\n#{e.backtrace.join("\n")}"
    method_missing_without_glimmer(method_symbol, *args, &block)
  end
end

$LOAD_PATH.unshift(File.expand_path('..', __FILE__))

require 'glimmer/swt/packages'
require 'glimmer/dsl'
