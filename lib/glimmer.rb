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
require 'fileutils'
require 'os'

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
        klass.extend(SWT::Packages)
        klass.extend(Glimmer)
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
      # unless defined? @@logger
      #   @@logger = Logger.new(STDOUT).tap {|logger| logger.level = Logger::WARN}
      # end
      @@logger if defined? @@logger
    end

    def enable_logging
      @@logger = Logger.new(STDOUT).tap {|logger| logger.level = Logger::WARN}
    end
  end

  def method_missing(method_symbol, *args, &block)
    # This if statement speeds up Glimmer in girb or whenever directly including on main object
    if method_symbol.to_s.match(REGEX_METHODS_EXCLUDED)
      raise InvalidKeywordError, "Glimmer excluded keyword: #{method_symbol}"
    end
    Glimmer.logger&.debug "Interpreting keyword: #{method_symbol}"
    Glimmer::DSL::Engine.interpret(method_symbol, *args, &block)
  rescue InvalidKeywordError => e
    if !method_symbol.to_s.match(REGEX_METHODS_EXCLUDED)
      Glimmer.logger&.error e.message
    end
    Glimmer.logger&.debug "#{e.message}\n#{e.backtrace.join("\n")}"
    super(method_symbol, *args, &block)
  end
end

if ENV['GLIMMER_LOGGER_LEVEL']
  Glimmer.enable_logging
  Glimmer.logger.level = ENV['GLIMMER_LOGGER_LEVEL'].downcase
end

$LOAD_PATH.unshift(File.expand_path('..', __FILE__))

require 'glimmer/launcher'
require Glimmer::Launcher.swt_jar_file # TODO move into swt/dsl.rb
require 'glimmer/swt/packages'
require 'glimmer/dsl/swt/dsl'
require 'glimmer/dsl/xml/dsl'
require 'glimmer/dsl/css/dsl'
require 'glimmer/error'
require 'glimmer/invalid_keyword_error'
