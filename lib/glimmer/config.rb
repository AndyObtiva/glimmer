module Glimmer
  module Config
    class << self
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
  end
end

if ENV['GLIMMER_LOGGER_LEVEL']
  Glimmer::Config.enable_logging
  Glimmer::Config.logger.level = ENV['GLIMMER_LOGGER_LEVEL'].downcase
end
